import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/client.dart';
import 'package:kiveto_mobile/features/scheduling/di.dart';
import 'package:kiveto_mobile/features/scheduling/domain/appointment.dart';
import 'package:kiveto_mobile/features/scheduling/domain/questionnaire.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/booking_layout.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_messages.dart';
import 'package:kiveto_mobile/features/scheduling/presentation/scheduling_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/domain/clinic_id.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
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

/// The longest treatment details and notes the contract takes.
const _detailsMaxLength = 500;
const _notesMaxLength = 1000;

/// Screen 15, « Avant la consultation » (mockup 15): the pre-visit
/// questionnaire of an appointment — the symptoms (« Rien de particulier »
/// alone, or the others), the ongoing treatment and which, how the visits
/// go, the notes — then « Envoyer à la clinique » once the symptoms, the
/// treatment and the temperament are answered. Answers already sent fill
/// the form, and sending again replaces them. Once the server closes the
/// questionnaire (`editable: false`), its answers are shown read-only.
///
/// Exits: [onBack]; [onSent] once the answers were saved (the appointments
/// screen).
class QuestionnairePage extends ConsumerStatefulWidget {
  const new({
    required this.appointmentId,
    required this.onBack,
    required this.onSent,
    super.key,
  });

  final String appointmentId;
  final void Function(BuildContext context) onBack;
  final void Function(BuildContext context) onSent;

  @override
  ConsumerState<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends ConsumerState<QuestionnairePage> {
  final _details = TextEditingController();
  final _notes = TextEditingController();

  /// The form, made from the questionnaire once it was read.
  QuestionnaireForm? _form;
  bool _sending = false;
  Object? _error;

  AppointmentId get _id => AppointmentId(widget.appointmentId);

  @override
  void dispose() {
    _details.dispose();
    _notes.dispose();
    super.dispose();
  }

  /// The form of [questionnaire], made once: from the answers already sent
  /// (their texts in the fields), else a new questionnaire.
  QuestionnaireForm _formOf(Questionnaire questionnaire) {
    if (_form case final form?) return form;
    final answers = questionnaire.answers;
    if (answers == null) return _form = const QuestionnaireForm.initial();
    _details.text = answers.treatmentDetails ?? '';
    _notes.text = answers.notes ?? '';
    return _form = QuestionnaireForm.from(answers);
  }

  void _change(QuestionnaireForm form) => setState(() {
    _form = form;
    _error = null;
  });

  /// A text edited: the last answer of the server no longer applies.
  void _edited() {
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _send(ClinicId clinicId) async {
    final answers = _form?.toAnswers(
      details: _details.text,
      notes: _notes.text,
    );
    if (answers == null || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    final repository = ref.read(questionnaireRepositoryProvider);
    final revision = ref.read(appointmentsRevisionProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final sent = AppLocalizations.of(context).questionnaireSent;
    try {
      await repository.save(clinicId, _id, answers);
      // Saved whatever became of the page: the banner of 4 and the home's
      // button go.
      revision.bump();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(sent)));
      if (!mounted) return;
      widget.onSent(context);
    } on Object catch (error) {
      // Closed meanwhile: the questionnaire read again shows its answers
      // read-only, the lists drop the banner.
      final cause = failureCause(error);
      final locked = switch (cause) {
        ApiFailure(code: 'questionnaire_locked') => true,
        _ => false,
      };
      // Closed, or the appointment gone (cancelled meanwhile): the lists and
      // the home show what the server says now.
      if (locked || cause is NotFoundFailure) revision.bump();
      if (!mounted) return;
      if (locked) ref.invalidate(questionnaireProvider(_id));
      setState(() {
        _sending = false;
        _error = locked ? null : error;
      });
    }
  }

  void _retryRead() {
    // A failure of /me reaches the questionnaire through the active clinic.
    if (ref.read(meProvider).hasError) ref.invalidate(meProvider);
    ref.invalidate(questionnaireProvider(_id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void back() => widget.onBack(context);
    final loading = _Plain(onBack: back, child: const LoadingView());
    // The header names the pet, the motif and the slot: the page waits for
    // the appointment too, and goes without when it failed.
    final appointmentRead = ref.watch(appointmentProvider(_id));
    final appointment = switch (appointmentRead) {
      AsyncData(:final value) => value.appointment,
      _ => null,
    };
    return switch (ref.watch(questionnaireProvider(_id))) {
      AsyncValue(isLoading: true, hasError: true) => loading,
      // Read again (closed on send): loading, not the form still live.
      AsyncData(:final value, isLoading: false)
          when appointmentRead is! AsyncLoading =>
        value.questionnaire.editable
            ? _page(context, l10n, value, appointment)
            : _LockedQuestionnaire(
                questionnaire: value.questionnaire,
                appointment: appointment,
                onBack: back,
              ),
      AsyncError(:final error) => _Plain(
        onBack: back,
        child: failureCause(error) is NotFoundFailure
            ? ErrorView(
                error: error,
                title: l10n.questionnaireNotFoundTitle,
                message: l10n.questionnaireNotFoundBody,
              )
            : ErrorView(error: error, onRetry: _retryRead),
      ),
      _ => loading,
    };
  }

  Widget _page(
    BuildContext context,
    AppLocalizations l10n,
    ClinicQuestionnaire read,
    Appointment? appointment,
  ) {
    final (:clinicId, :questionnaire) = read;
    final form = _formOf(questionnaire);
    final pet = appointment?.petName;
    final sentAt = switch (questionnaire) {
      Questionnaire(
        status: QuestionnaireStatus.submitted,
        updatedAt: final at?,
      ) =>
        questionnaireSentAt(at),
      _ => null,
    };
    final error = _error;
    final sending = _sending;
    return FlowScaffold(
      gap: KivetoSpace.xl5,
      // The server's answer sits above the button: the body may be
      // scrolled anywhere when it comes.
      bar: StickyCtaBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null) ...[
              KivetoCallout.danger(
                body: questionnaireFailureMessage(l10n, error),
                actionLabel: isTransientFailure(error)
                    ? l10n.commonRetry
                    : null,
                onAction: () => unawaited(_send(clinicId)),
              ),
              const SizedBox(height: KivetoSpace.m),
            ],
            KivetoButton.primary(
              label: l10n.questionnaireSend,
              loading: sending,
              onPressed: form.isComplete && !sending
                  ? () => unawaited(_send(clinicId))
                  : null,
            ),
          ],
        ),
      ),
      children: [
        _Back(onBack: () => widget.onBack(context)),
        _Header(
          appointment: appointment,
          extra: switch (sentAt) {
            (final date, final time) => l10n.questionnaireSentOn(date, time),
            null => l10n.questionnaireIntro,
          },
        ),
        _Fieldset(
          legend: l10n.questionnaireSymptomsLegend,
          child: _SymptomChips(
            selected: form.symptoms,
            onToggle: sending
                ? null
                : (symptom) => _change(form.toggle(symptom)),
          ),
        ),
        _Fieldset(
          legend: pet == null
              ? l10n.questionnaireTreatmentLegendNoPet
              : l10n.questionnaireTreatmentLegend(pet),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TreatmentChips(
                selected: form.ongoingTreatment,
                onSelected: sending
                    ? null
                    : (ongoing) =>
                          _change(form.withTreatment(ongoing: ongoing)),
              ),
              if (form.ongoingTreatment ?? false) ...[
                const SizedBox(height: KivetoSpace.ml),
                KivetoTextField.multiline(
                  label: l10n.questionnaireTreatmentDetails,
                  hintText: l10n.questionnaireTreatmentDetailsHint,
                  largeLabel: false,
                  controller: _details,
                  maxLength: _detailsMaxLength,
                  enabled: !sending,
                  onChanged: (_) => _edited(),
                ),
              ],
            ],
          ),
        ),
        _Fieldset(
          legend: pet == null
              ? l10n.questionnaireTemperamentLegendNoPet
              : l10n.questionnaireTemperamentLegend(pet),
          child: _TemperamentChips(
            selected: form.temperament,
            onSelected: sending
                ? null
                : (temperament) => _change(form.withTemperament(temperament)),
          ),
        ),
        KivetoTextField.multiline(
          label: l10n.questionnaireNotes,
          optional: true,
          controller: _notes,
          minLines: 3,
          maxLines: 5,
          maxLength: _notesMaxLength,
          enabled: !sending,
          onChanged: (_) => _edited(),
        ),
      ],
    );
  }
}

/// The questionnaire the server closed (C-33a callout): the answers sent,
/// read-only — the same fieldsets, chips that do not react, the texts in
/// a canvas box — or the line saying it was not filled. No bar.
class _LockedQuestionnaire extends StatelessWidget {
  const new({
    required this.questionnaire,
    required this.appointment,
    required this.onBack,
  });

  final Questionnaire questionnaire;
  final Appointment? appointment;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final answers = questionnaire.answers;
    final pet = appointment?.petName;
    final sentAt = switch (questionnaire) {
      Questionnaire(
        status: QuestionnaireStatus.submitted,
        updatedAt: final at?,
      ) =>
        questionnaireSentAt(at),
      _ => null,
    };
    return FlowScaffold(
      gap: KivetoSpace.xl5,
      children: [
        _Back(onBack: onBack),
        _Header(
          appointment: appointment,
          extra: switch (sentAt) {
            (final date, final time) => l10n.questionnaireLockedSentOn(
              date,
              time,
            ),
            null => null,
          },
        ),
        KivetoCallout.info(
          title: l10n.questionnaireLockedTitle,
          body: l10n.questionnaireLockedBody,
        ),
        if (answers == null)
          Text(l10n.questionnaireLockedEmpty, style: KivetoText.bodyLarge)
        else ...[
          _Fieldset(
            legend: l10n.questionnaireSymptomsLegend,
            child: _SymptomChips(selected: answers.symptoms),
          ),
          _Fieldset(
            legend: pet == null
                ? l10n.questionnaireTreatmentLegendNoPet
                : l10n.questionnaireTreatmentLegend(pet),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TreatmentChips(selected: answers.ongoingTreatment),
                if (answers.treatmentDetails case final details?
                    when answers.ongoingTreatment) ...[
                  const SizedBox(height: KivetoSpace.ml),
                  _Answer(
                    label: l10n.questionnaireTreatmentDetails,
                    text: details,
                    style: KivetoText.labelSmall,
                  ),
                ],
              ],
            ),
          ),
          _Fieldset(
            legend: pet == null
                ? l10n.questionnaireTemperamentLegendNoPet
                : l10n.questionnaireTemperamentLegend(pet),
            child: _TemperamentChips(selected: answers.temperament),
          ),
          if (answers.notes case final notes?)
            _Answer(
              label: l10n.questionnaireNotes,
              text: notes,
              style: KivetoText.sectionTitle,
            ),
        ],
      ],
    );
  }
}

/// C-37c without its back (the back sits alone above it, 24 apart):
/// « Avant la consultation », the appointment (pet · motif · slot) once
/// read, and [extra].
class _Header extends StatelessWidget {
  const new({required this.appointment, required this.extra});

  final Appointment? appointment;
  final String? extra;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appointment = this.appointment;
    String? subtitle;
    if (appointment != null) {
      // « lun. 9 nov. à 14:15 » stays on one line.
      final slot = slotShort(
        l10n,
        appointment.startAt,
        capitalized: false,
      ).replaceAll(' ', '\u00a0');
      subtitle = switch (appointment.petName) {
        final String pet => l10n.questionnaireSubtitle(
          pet,
          appointment.motifLabel,
          slot,
        ),
        null => l10n.questionnaireSubtitleNoPet(appointment.motifLabel, slot),
      };
    }
    return KivetoDetailHeader(
      title: l10n.screenQuestionnaireTitle,
      subtitle: subtitle,
      extra: extra,
    );
  }
}

/// C-9a alone on its row, its glyph on the gutter.
class _Back extends StatelessWidget {
  const new({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: KivetoIconButton.back(onPressed: onBack),
  );
}

/// A group of choices with its legend (16/700, 12 above the choices),
/// announced as one group.
class _Fieldset extends StatelessWidget {
  const new({required this.legend, required this.child});

  final String legend;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: legend,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(child: Text(legend, style: KivetoText.sectionTitle)),
        const SizedBox(height: KivetoSpace.ml),
        child,
      ],
    ),
  );
}

/// The symptom chips (C-13b, wrap, gap 8); read-only without [onToggle].
class _SymptomChips extends StatelessWidget {
  const new({required this.selected, this.onToggle});

  final Set<Symptom> selected;
  final ValueChanged<Symptom>? onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onToggle = this.onToggle;
    return _Chips(
      children: [
        for (final symptom in Symptom.values)
          if (symptomLabel(l10n, symptom) case final label?)
            KivetoChoiceChip(
              label: label,
              selected: selected.contains(symptom),
              onSelected: onToggle == null ? null : () => onToggle(symptom),
            ),
      ],
    );
  }
}

/// « Non » and « Oui » (C-13b, gap 8); read-only without [onSelected].
class _TreatmentChips extends StatelessWidget {
  const new({required this.selected, this.onSelected});

  final bool? selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSelected = this.onSelected;
    return _Chips(
      children: [
        for (final (value, label) in [
          (false, l10n.questionnaireTreatmentNo),
          (true, l10n.questionnaireTreatmentYes),
        ])
          KivetoChoiceChip(
            label: label,
            selected: selected == value,
            onSelected: onSelected == null ? null : () => onSelected(value),
          ),
      ],
    );
  }
}

/// The temperament chips (C-13b, wrap, gap 8); read-only without
/// [onSelected].
class _TemperamentChips extends StatelessWidget {
  const new({required this.selected, this.onSelected});

  final Temperament? selected;
  final ValueChanged<Temperament>? onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSelected = this.onSelected;
    return _Chips(
      children: [
        for (final temperament in Temperament.values)
          if (temperamentLabel(l10n, temperament) case final label?)
            KivetoChoiceChip(
              label: label,
              selected: selected == temperament,
              onSelected: onSelected == null
                  ? null
                  : () => onSelected(temperament),
            ),
      ],
    );
  }
}

/// Chips wrapping 8 apart.
class _Chips extends StatelessWidget {
  const new({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: KivetoSpace.sm,
    runSpacing: KivetoSpace.sm,
    children: children,
  );
}

/// A text answer of a closed questionnaire: its label, the text (15) in a
/// canvas box.
class _Answer extends StatelessWidget {
  const new({required this.label, required this.text, required this.style});

  final String label;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: style),
      const SizedBox(height: KivetoSpace.s),
      DecoratedBox(
        decoration: BoxDecoration(
          color: KivetoColors.canvas,
          borderRadius: BorderRadius.circular(KivetoRadius.m),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Text(text, style: KivetoText.input),
        ),
      ),
    ],
  );
}

/// A page of the questionnaire without its form: back, and [child]
/// (loading, a failure).
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
