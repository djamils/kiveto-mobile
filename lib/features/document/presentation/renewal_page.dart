import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/document/di.dart';
import 'package:kiveto_mobile/features/document/domain/document.dart';
import 'package:kiveto_mobile/features/document/domain/prescription.dart';
import 'package:kiveto_mobile/features/document/domain/renewal.dart';
import 'package:kiveto_mobile/features/document/presentation/documents_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/domain/intent_key.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The longest note the contract takes.
const _noteMaxLength = 500;

/// The id of the active clinic, for the account of the session
/// (`selectAsync`: no new value while `/me` reloads, nor for the same id).
final FutureProvider<ClinicId?> _clinicIdProvider = FutureProvider<ClinicId?>((
  ref,
) {
  ref.watch(sessionStatusProvider);
  return ref.watch(
    activeClinicProvider.selectAsync((clinic) => clinic?.clinicId),
  );
});

/// Screen 17, « Demander un renouvellement » (mockup 17): the prescription
/// (its date, vet and pet), its lines read-only (the request covers the
/// whole prescription), how the pet does with the treatment (a warning
/// when it does not help or has adverse effects), a note for the vet, then
/// « Envoyer la demande » once a condition is chosen; then « Demande
/// envoyée ». Whether the prescription may be renewed online is the
/// server's answer (`422 prescription_not_renewable`).
///
/// Exits: [onBack]; [onDone] (« Retour aux documents », back on the
/// success).
class RenewalPage extends ConsumerStatefulWidget {
  const new({
    required this.prescriptionId,
    required this.onBack,
    required this.onDone,
    super.key,
  });

  final String prescriptionId;
  final void Function(BuildContext context) onBack;
  final void Function(BuildContext context) onDone;

  @override
  ConsumerState<RenewalPage> createState() => _RenewalPageState();
}

class _RenewalPageState extends ConsumerState<RenewalPage> {
  final _note = TextEditingController();

  /// One key per content: a retry of the same request sends the same key.
  late final _intent = IntentKey<RenewalRequestDraft>(
    ref.read(idempotencyKeyFactoryProvider),
  );
  PetCondition? _condition;
  bool _sending = false;
  Object? _error;

  /// The request the server recorded.
  RenewalReceipt? _receipt;

  PrescriptionId get _id => PrescriptionId(widget.prescriptionId);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _send(ClinicId clinicId) async {
    final condition = _condition;
    if (condition == null || _sending) return;
    final draft = RenewalRequestDraft(
      condition: condition,
      note: switch (_note.text.trim()) {
        '' => null,
        final note => note,
      },
    );
    final key = _intent.keyFor(draft);
    setState(() {
      _sending = true;
      _error = null;
    });
    final repository = ref.read(renewalRepositoryProvider);
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      final receipt = await repository.requestRenewal(
        clinicId,
        _id,
        draft,
        key,
      );
      // Sent whatever became of the page: every documents list reloads,
      // the card's sheet then shows « Renouvellement demandé ».
      container.invalidate(documentListProvider);
      if (!mounted) return;
      setState(() {
        _sending = false;
        _receipt = receipt;
      });
    } on Object catch (error) {
      // The prescription is gone: the lists drop its card.
      if (_cause(error) is NotFoundFailure) {
        container.invalidate(documentListProvider);
      }
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = error;
      });
    }
  }

  void _retryClinic() {
    if (ref.read(meProvider).hasError) ref.invalidate(meProvider);
    ref.invalidate(_clinicIdProvider);
  }

  @override
  Widget build(BuildContext context) {
    if (_receipt != null) return _Sent(onDone: widget.onDone);
    final l10n = AppLocalizations.of(context);
    void back() => widget.onBack(context);
    final loading = _Plain(onBack: back, child: const LoadingView());
    final gone = _Plain(
      onBack: back,
      child: ErrorView(
        error: const NotFoundFailure(),
        title: l10n.documentsPrescriptionGoneTitle,
        message: l10n.documentsPrescriptionGoneBody,
      ),
    );
    switch (ref.watch(_clinicIdProvider)) {
      case AsyncValue(isLoading: true, hasError: true):
        return loading;
      case AsyncData(value: null):
        return gone;
      case AsyncData(value: final clinicId?):
        final provider = prescriptionProvider((clinicId, _id));
        return switch (ref.watch(provider)) {
          AsyncValue(isLoading: true, hasError: true) => loading,
          AsyncData(:final value) => _form(context, l10n, clinicId, value),
          AsyncError(:final error) when _cause(error) is NotFoundFailure =>
            gone,
          AsyncError(:final error) => _Plain(
            onBack: back,
            child: ErrorView(
              error: error,
              onRetry: () => ref.invalidate(provider),
            ),
          ),
          _ => loading,
        };
      case AsyncError(:final error):
        return _Plain(
          onBack: back,
          child: ErrorView(error: error, onRetry: _retryClinic),
        );
      default:
        return loading;
    }
  }

  Widget _form(
    BuildContext context,
    AppLocalizations l10n,
    ClinicId clinicId,
    Prescription prescription,
  ) {
    final condition = _condition;
    final error = _error;
    final sending = _sending;
    final pet = prescription.pet.name;
    // A violation of the note shows under it, any other in the callout.
    final noteError = switch (error) {
      ValidationFailure(:final violations) =>
        violations
            .where((violation) => violation.propertyPath == 'note')
            .firstOrNull
            ?.message,
      _ => null,
    };
    final message = error == null
        ? null
        : renewalFailureMessage(l10n, error, shown: const {'note'});
    return _FormScaffold(
      // The server's answer sits above the button: the body may be
      // scrolled anywhere when it comes.
      bar: StickyCtaBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (message != null) ...[
              KivetoCallout.danger(
                body: message,
                actionLabel: _isTransient(error!) ? l10n.commonRetry : null,
                onAction: () => unawaited(_send(clinicId)),
              ),
              const SizedBox(height: KivetoSpace.m),
            ],
            KivetoButton.primary(
              label: l10n.renewalSend,
              loading: sending,
              onPressed: condition == null || sending
                  ? null
                  : () => unawaited(_send(clinicId)),
            ),
          ],
        ),
      ),
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: KivetoIconButton.back(onPressed: () => widget.onBack(context)),
        ),
        KivetoDetailHeader(
          title: l10n.screenPrescriptionRenewalTitle,
          subtitle: l10n.renewalSubtitle(
            // « 2 nov. 2026 » stays on one line.
            KivetoFormat.dayMonthYear(prescription.issuedAt.date)
                .replaceAll(' ', '\u00a0'),
            prescription.vet,
            pet,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KivetoSectionHeader(l10n.renewalLinesLegend),
            const SizedBox(height: KivetoSpace.m),
            if (prescription.lines.isNotEmpty) ...[
              KivetoCard.list(
                children: [
                  for (final line in prescription.lines)
                    _LineRow(
                      title: line.label,
                      meta: l10n.documentsPrescriptionLine(
                        line.quantity,
                        line.posologySummary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: KivetoSpace.m),
            ],
            KivetoFootnote(l10n.renewalLinesCaption, small: true),
          ],
        ),
        Semantics(
          container: true,
          label: l10n.renewalConditionLegend(pet),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: Text(
                  l10n.renewalConditionLegend(pet),
                  style: KivetoText.sectionTitle,
                ),
              ),
              const SizedBox(height: KivetoSpace.m),
              Wrap(
                spacing: KivetoSpace.sm,
                runSpacing: KivetoSpace.sm,
                children: [
                  for (final (value, label) in [
                    (PetCondition.improved, l10n.renewalConditionImproved),
                    (
                      PetCondition.noImprovement,
                      l10n.renewalConditionNoImprovement,
                    ),
                    (
                      PetCondition.adverseEffects,
                      l10n.renewalConditionAdverseEffects,
                    ),
                  ])
                    KivetoChoiceChip(
                      label: label,
                      selected: value == condition,
                      onSelected: sending
                          ? null
                          : () => setState(() {
                              _condition = value;
                              _error = null;
                            }),
                    ),
                ],
              ),
              if (condition == PetCondition.noImprovement ||
                  condition == PetCondition.adverseEffects) ...[
                const SizedBox(height: KivetoSpace.m),
                KivetoCallout.warning(body: l10n.renewalConditionWarning),
              ],
            ],
          ),
        ),
        KivetoTextField.multiline(
          label: l10n.renewalNote,
          optional: true,
          controller: _note,
          minLines: 3,
          maxLines: 5,
          maxLength: _noteMaxLength,
          enabled: !sending,
          errorText: noteError,
          onChanged: (_) {
            // The last answer of the server no longer applies.
            if (_error != null) setState(() => _error = null);
          },
        ),
        KivetoFootnote(l10n.renewalFootnote),
      ],
    );
  }
}

/// The error a provider failed with (a dependency's error arrives wrapped
/// in [ProviderException]s).
Object _cause(Object error) =>
    error is ProviderException ? _cause(error.exception) : error;

/// The failure may go away by sending the same request again (the
/// network, the server): the same key goes with it.
bool _isTransient(Object error) => switch (_cause(error)) {
  NetworkFailure() || ServerFailure() => true,
  _ => false,
};

/// The French message of a renewal request the server did not take: a
/// violation no field shows (those of [shown] sit under their field: none
/// then), the codes of the Portal API (the server's reason after a refusal
/// of the prescription), else the shared message of the failure kind.
String? renewalFailureMessage(
  AppLocalizations l10n,
  Object error, {
  Set<String> shown = const {},
}) => switch (_cause(error)) {
  ValidationFailure(:final violations) when violations.isNotEmpty =>
    violations
        .where((violation) => !shown.contains(violation.propertyPath))
        .firstOrNull
        ?.message,
  ApiFailure(code: 'prescription_not_renewable', :final detail) =>
    switch (detail?.trim()) {
      final String reason when reason.isNotEmpty =>
        '${l10n.renewalNotRenewable} $reason',
      _ => l10n.renewalNotRenewable,
    },
  RateLimitedFailure() => l10n.requestRateLimited,
  NotFoundFailure() => l10n.documentsPrescriptionGoneBody,
  final other => failureMessage(l10n, other).$2,
};

/// A line of the prescription, read-only (C-11i's size without its
/// checkbox): min-height 60, padding 10 16, the label (15/700) over
/// « Qté … · … » (13).
class _LineRow extends StatelessWidget {
  const new({required this.title, required this.meta});

  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: 60),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: KivetoText.itemTitle),
            const SizedBox(height: KivetoSpace.xxs),
            Text(meta, style: KivetoText.bodySmall),
          ],
        ),
      ),
    ),
  );
}

/// The form page on white (mockup 17): a scrolling body (padding 16 20 16,
/// blocks 22 apart) and [bar] at the bottom.
class _FormScaffold extends StatelessWidget {
  const new({required this.children, required this.bar});

  final List<Widget> children;
  final Widget bar;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: KivetoColors.surface,
    body: SafeArea(
      // The bar keeps the bottom inset itself.
      bottom: false,
      child: Column(
        children: [
          Expanded(
            // A drag closes the keyboard (an iOS multiline field has no
            // dismiss key), also when the content fits.
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                KivetoSpace.gutter,
                KivetoSpace.xl,
                KivetoSpace.gutter,
                KivetoSpace.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(height: KivetoSpace.xl4),
                    children[i],
                  ],
                ],
              ),
            ),
          ),
          bar,
        ],
      ),
    ),
  );
}

/// A page of the renewal without its form: back, and [child] (loading, a
/// failure).
class _Plain extends StatelessWidget {
  const new({required this.onBack, required this.child});

  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: KivetoColors.surface,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KivetoSpace.gutter,
          KivetoSpace.xl,
          KivetoSpace.gutter,
          KivetoSpace.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KivetoIconButton.back(onPressed: onBack),
            Expanded(child: Center(child: child)),
          ],
        ),
      ),
    ),
  );
}

/// The success of the request (C-34a): « Demande envoyée », what comes
/// next, « Retour aux documents » (back too).
class _Sent extends StatelessWidget {
  const new({required this.onDone});

  final void Function(BuildContext context) onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onDone(context);
      },
      child: Scaffold(
        backgroundColor: KivetoColors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: SuccessView(
                      title: l10n.renewalDoneTitle,
                      message: l10n.renewalDoneBody,
                    ),
                  ),
                ),
              ),
              BottomCtaArea(
                success: true,
                children: [
                  KivetoButton.primary(
                    label: l10n.renewalDoneBack,
                    onPressed: () => onDone(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
