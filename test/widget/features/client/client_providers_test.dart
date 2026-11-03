// meProvider follows the session (never the previous account's value while
// it reloads); activeClinicProvider: the stored choice, the default, an
// unreadable store, select.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/client/domain/active_clinic_store.dart';
import 'package:kiveto_mobile/features/client/domain/me_repository.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';

import '../../../support/fakes.dart';

const _paris = ClinicId('paris');
const _lyon = ClinicId('lyon');

Me _me(String accountId) => Me(
  account: Account(
    id: accountId,
    maskedPhone: '+33 6 •• •• •• 78',
    firstName: 'Julien',
  ),
  clinics: [
    for (final id in [_paris, _lyon])
      ClinicLink(
        clinicId: id,
        name: 'Clinique ${id.value}',
        timezone: 'Europe/Paris',
        linkStatus: LinkStatus.confirmed,
        unreadDocuments: id == _paris ? 1 : 0,
      ),
  ],
);

/// Answers the account of the current session's access token; [gate]
/// holds the answers until it completes.
final class _Repository implements MeRepository {
  new(this._session);

  final SessionManager _session;
  Completer<void>? gate;
  int calls = 0;

  /// Thrown instead of an answer.
  ApiFailure? failure;

  @override
  Future<Me> me() async {
    calls++;
    final account = 'acc-${_session.tokens!.accessToken}';
    await gate?.future;
    if (failure case final ApiFailure failure) throw failure;
    return _me(account);
  }
}

/// A store whose reads wait for [gate].
final class _GatedStore implements ActiveClinicStore {
  final gate = Completer<void>();
  final choices = <String, String>{};

  @override
  Future<String?> read(String accountId) async {
    await gate.future;
    return choices[accountId];
  }

  @override
  Future<void> write(String accountId, String clinicId) async =>
      choices[accountId] = clinicId;
}

void main() {
  late SessionManager session;
  late _Repository repository;
  late InMemoryActiveClinicStore store;

  Future<ProviderContainer> start({
    String? tokens = 'A',
    ActiveClinicStore? activeClinicStore,
  }) async {
    session = await memorySession(tokens == null ? null : pair(tokens));
    repository = _Repository(session);
    store = InMemoryActiveClinicStore();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sessionManagerProvider.overrideWithValue(session),
        meRepositoryProvider.overrideWithValue(repository),
        activeClinicStoreProvider.overrideWithValue(activeClinicStore ?? store),
      ],
    );
    addTearDown(container.dispose);
    container.listen(activeClinicProvider, (_, _) {});
    return container;
  }

  group('meProvider', () {
    test('signed out: unauthorized, without a call', () async {
      final container = await start(tokens: null);

      await expectLater(
        container.read(meProvider.future),
        throwsA(isA<UnauthorizedFailure>()),
      );
      expect(repository.calls, 0);
    });

    test('a new session reloads it; the previous account is never data '
        'meanwhile; a refresh does not reload', () async {
      final container = await start();
      expect((await container.read(meProvider.future)).account.id, 'acc-A');

      await session.replaceTokens(expected: pair('A'), next: pair('A2'));
      expect(container.read(meProvider), isA<AsyncData<Me>>());
      expect(repository.calls, 1);

      repository.gate = Completer<void>();
      await session.open(pair('B'));
      final reloading = container.read(meProvider);
      expect(reloading, isNot(isA<AsyncData<Me>>()));
      expect(reloading.isLoading, isTrue);
      expect(
        container.read(activeClinicProvider),
        isNot(isA<AsyncData<Object?>>()),
      );

      repository.gate!.complete();
      expect((await container.read(meProvider.future)).account.id, 'acc-B');
      expect(repository.calls, 2);

      await session.signOut();
      expect(container.read(meProvider), isA<AsyncError<Me>>());
    });
  });

  group('activeClinicProvider', () {
    test('no choice stored: the first confirmed clinic', () async {
      final container = await start();

      final clinic = await container.read(activeClinicProvider.future);

      expect(clinic?.clinicId, _paris);
    });

    test('the choice stored for this account', () async {
      final container = await start();
      store.choices['acc-A'] = 'lyon';

      expect(
        (await container.read(activeClinicProvider.future))?.clinicId,
        _lyon,
      );
    });

    test('an unreadable store: the default clinic', () async {
      final container = await start();
      store.failing = true;

      expect(
        (await container.read(activeClinicProvider.future))?.clinicId,
        _paris,
      );
    });

    test('select: the clinic, kept for this account; an unknown one is '
        'ignored', () async {
      final container = await start();
      await container.read(activeClinicProvider.future);

      await container.read(activeClinicProvider.notifier).select(_lyon);

      expect(container.read(activeClinicProvider).value?.clinicId, _lyon);
      expect(store.choices, {'acc-A': 'lyon'});

      await container
          .read(activeClinicProvider.notifier)
          .select(const ClinicId('gone'));
      expect(container.read(activeClinicProvider).value?.clinicId, _lyon);
      expect(store.choices, {'acc-A': 'lyon'});
    });

    test('select while /me is in error: nothing, no throw', () async {
      final container = await start();
      repository.failure = const ServerFailure(statusCode: 503);
      container.invalidate(meProvider);
      await expectLater(
        container.read(activeClinicProvider.future),
        throwsA(isA<ServerFailure>()),
      );

      await container.read(activeClinicProvider.notifier).select(_lyon);

      expect(store.choices, isEmpty);
      expect(container.read(activeClinicProvider), isA<AsyncError<Object?>>());
    });

    test('select while the build still reads the store: the choice is '
        'kept, not overwritten by the build', () async {
      final gated = _GatedStore();
      final container = await start(activeClinicStore: gated);

      final selecting = container
          .read(activeClinicProvider.notifier)
          .select(_lyon);
      await pumpEventQueue();
      gated.gate.complete();
      await selecting;

      expect(container.read(activeClinicProvider).value?.clinicId, _lyon);
      expect(gated.choices, {'acc-A': 'lyon'});
    });

    test('select with a store that cannot write: the choice holds', () async {
      final container = await start();
      await container.read(activeClinicProvider.future);
      store.failing = true;

      await container.read(activeClinicProvider.notifier).select(_lyon);

      expect(container.read(activeClinicProvider).value?.clinicId, _lyon);
    });

    test('another account does not inherit the choice', () async {
      final container = await start();
      store.choices['acc-A'] = 'lyon';
      await container.read(activeClinicProvider.future);

      await session.open(pair('B'));

      expect(
        (await container.read(activeClinicProvider.future))?.clinicId,
        _paris,
      );
    });
  });
}
