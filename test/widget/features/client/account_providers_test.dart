// The account-scoped providers of screen 6: the data exports refused
// signed out without a call; the consents of the active clinic follow a new
// account signed in, never showing the previous account's meanwhile.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/core/security/session_manager.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/client/domain/consent.dart';
import 'package:kiveto_mobile/features/client/domain/consent_repository.dart';
import 'package:kiveto_mobile/features/client/domain/data_export.dart';
import 'package:kiveto_mobile/features/client/domain/data_export_repository.dart';
import 'package:kiveto_mobile/features/client/domain/me_repository.dart';
import 'package:kiveto_mobile/features/client/domain/profile_update.dart';
import 'package:kiveto_mobile/features/client/presentation/account_providers.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/portal_file.dart';

import '../../../support/fakes.dart';

const _paris = ClinicId('paris');

/// The account of the session's access token (`acc-A`), Paris confirmed.
final class _Me implements MeRepository {
  new(this._session);

  final SessionManager _session;

  @override
  Future<Me> me() async => Me(
    account: Account(
      id: 'acc-${_session.tokens!.accessToken}',
      maskedPhone: '+33 6 •• •• •• 78',
    ),
    clinics: const [
      ClinicLink(
        clinicId: _paris,
        name: 'Clinique Paris',
        timezone: 'Europe/Paris',
        linkStatus: LinkStatus.confirmed,
      ),
    ],
  );

  @override
  Future<Account> updateProfile(ProfileUpdate update) =>
      throw UnimplementedError('not used by these tests');
}

/// The consents of the session's account: marketing by SMS for A, by
/// e-mail for any other; [gate] holds the answers until it completes.
final class _Consents implements ConsentRepository {
  new(this._session);

  final SessionManager _session;
  Completer<void>? gate;

  /// The account each read was for.
  final reads = <String>[];

  @override
  Future<ClinicConsents> consents(ClinicId clinicId) async {
    final account = _session.tokens!.accessToken;
    reads.add(account);
    await gate?.future;
    return ClinicConsents([
      Consent(
        kind: ConsentKind.marketing,
        channels: {
          if (account == 'A') ConsentChannel.sms else ConsentChannel.email,
        },
        effect: ConsentEffect.sendControl,
      ),
    ]);
  }

  @override
  Future<ClinicConsents> update(
    ClinicId clinicId,
    ConsentKind kind,
    Set<ConsentChannel> channels,
  ) => throw UnimplementedError('not used by these tests');

  @override
  Future<ConsentHistoryPage> history(ClinicId clinicId, {String? cursor}) =>
      throw UnimplementedError('not used by these tests');
}

/// Counts the reads of the exports.
final class _Exports implements DataExportRepository {
  int calls = 0;

  @override
  Future<List<DataExport>> exports() async {
    calls++;
    return const [];
  }

  @override
  Future<String> request() => throw UnimplementedError();

  @override
  Future<PortalFile> download(String id) => throw UnimplementedError();
}

void main() {
  late SessionManager session;
  late _Consents consents;
  late _Exports exports;

  Future<ProviderContainer> start({String? tokens = 'A'}) async {
    session = await memorySession(tokens == null ? null : pair(tokens));
    consents = _Consents(session);
    exports = _Exports();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        sessionManagerProvider.overrideWithValue(session),
        meRepositoryProvider.overrideWithValue(_Me(session)),
        activeClinicStoreProvider.overrideWithValue(
          InMemoryActiveClinicStore(),
        ),
        consentRepositoryProvider.overrideWithValue(consents),
        dataExportRepositoryProvider.overrideWithValue(exports),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('dataExportsProvider', () {
    test('signed out: unauthorized, without a call', () async {
      final container = await start(tokens: null);
      container.listen(dataExportsProvider, (_, _) {});

      await expectLater(
        container.read(dataExportsProvider.future),
        throwsA(isA<UnauthorizedFailure>()),
      );
      expect(exports.calls, 0);
    });

    test('signed in: the exports of the account', () async {
      final container = await start();
      container.listen(dataExportsProvider, (_, _) {});

      expect(await container.read(dataExportsProvider.future), isEmpty);
      expect(exports.calls, 1);
    });
  });

  group('consentsProvider', () {
    test('another account signed in: its consents, never the previous '
        "account's meanwhile", () async {
      final container = await start();
      container.listen(consentsProvider, (_, _) {});

      final first = (await container.read(consentsProvider.future))!;
      expect(first.clinicId, _paris);
      expect(first.consents.of(ConsentKind.marketing)?.channels, {
        ConsentChannel.sms,
      });

      consents.gate = Completer<void>();
      await session.open(pair('B'));
      await pumpEventQueue();

      final reloading = container.read(consentsProvider);
      expect(reloading, isNot(isA<AsyncData<ConsentsState?>>()));
      expect(reloading.isLoading, isTrue);

      consents.gate!.complete();
      final second = (await container.read(consentsProvider.future))!;
      expect(second.clinicId, _paris);
      expect(second.consents.of(ConsentKind.marketing)?.channels, {
        ConsentChannel.email,
      });
      expect(consents.reads, ['A', 'B']);
    });

    test('signed out: no consent read', () async {
      final container = await start(tokens: null);
      container.listen(consentsProvider, (_, _) {});

      await expectLater(
        container.read(consentsProvider.future),
        throwsA(anything),
      );
      expect(consents.reads, isEmpty);
    });
  });
}
