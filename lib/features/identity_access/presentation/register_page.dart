import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/identity_access/di.dart';
import 'package:kiveto_mobile/features/identity_access/domain/registration_request.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/flows.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/identity_messages.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/terms_consent.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/formatters/kiveto_format.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/pills.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 9, the account of a verified number without invitation: first
/// and last names, an optional email, the terms (`RegisterAccount`).
///
/// A success needs no exit: the session opens and the router leaves this
/// sign-in-only page. [onRestart] goes back to the welcome page (back, a
/// grant no longer valid, a page opened without its flow).
class RegisterPage extends ConsumerStatefulWidget {
  const new({required this.onRestart, super.key});

  final void Function(BuildContext context) onRestart;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  bool _accepted = false;
  bool _sending = false;
  Map<String, String> _fieldErrors = const {};
  String? _error;
  bool _restartable = false;
  RegistrationFlowState? _shown;

  @override
  void initState() {
    super.initState();
    if (ref.read(registrationFlowProvider) == null) {
      leaveWhenShown(context, () => widget.onRestart(context));
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }

  void _restart() {
    ref.read(registrationFlowProvider.notifier).clear();
    widget.onRestart(context);
  }

  void _edited(String field) {
    if (!_fieldErrors.containsKey(field) && _error == null) {
      setState(() {});
      return;
    }
    setState(() {
      _fieldErrors = {..._fieldErrors}..remove(field);
      if (!_restartable) _error = null;
    });
  }

  Future<void> _submit() async {
    final flow = ref.read(registrationFlowProvider);
    final terms = ref.read(currentTermsProvider);
    // Not while the terms reload (after a terms_outdated): their version
    // would be the stale one.
    if (flow == null || terms is! AsyncData || terms.isLoading || _sending) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final email = _email.text.trim();
    final registrationFlow = ref.read(registrationFlowProvider.notifier);
    setState(() {
      _sending = true;
      _error = null;
      _fieldErrors = const {};
      _restartable = false;
    });
    try {
      await ref.read(registerAccountProvider)(
        RegistrationRequest(
          grant: flow.grant,
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          email: email.isEmpty ? null : email,
          termsVersion: terms.requireValue.version,
        ),
      );
      // Signed in: the router leaves this page for the home.
      registrationFlow.clear();
    } on Object catch (error) {
      if (!mounted) return;
      if (error case ApiFailure(code: 'terms_outdated')) {
        ref.invalidate(currentTermsProvider);
      }
      setState(() {
        _sending = false;
        switch (error) {
          case ValidationFailure(:final violations):
            const known = {'firstName', 'lastName', 'email'};
            _fieldErrors = {
              for (final violation in violations)
                if (known.contains(violation.propertyPath))
                  violation.propertyPath: violation.message,
            };
            // A violation no field shows (or none at all): the general
            // message.
            if (violations.isEmpty ||
                violations.any((v) => !known.contains(v.propertyPath))) {
              _error = failureMessage(l10n, error).$2;
            }
          case ApiFailure(code: 'terms_outdated'):
            _accepted = false;
            _error = identityErrorText(l10n, error);
          default:
            _error = identityErrorText(l10n, error);
            _restartable = isRestartFailure(error);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // A flow cleared on the way out stays shown while the page leaves.
    final flow = _shown = ref.watch(registrationFlowProvider) ?? _shown;
    if (flow == null) {
      return const Scaffold(backgroundColor: KivetoColors.surface);
    }
    final l10n = AppLocalizations.of(context);
    final terms = ref.watch(currentTermsProvider);
    final error = _error;
    final ready =
        _firstName.text.trim().isNotEmpty &&
        _lastName.text.trim().isNotEmpty &&
        _accepted &&
        terms is AsyncData &&
        !terms.isLoading;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _restart();
      },
      child: Scaffold(
        backgroundColor: KivetoColors.surface,
        body: SafeArea(
          bottom: false,
          // iOS phone and number pads have no return key: a drag closes them.
          child: KeyboardDismissOnDrag(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      KivetoSpace.authGutter,
                      KivetoSpace.xl,
                      KivetoSpace.authGutter,
                      kivetoBottomPadding(context, 28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: KivetoIconButton.back(onPressed: _restart),
                            ),
                            const SizedBox(height: KivetoSpace.xl4),
                            KivetoTag.success(
                              l10n.identityRegisterVerified(
                                KivetoFormat.phone(flow.phone.e164),
                              ),
                            ),
                            const SizedBox(height: KivetoSpace.sm),
                            Semantics(
                              header: true,
                              child: Text(
                                l10n.screenRegisterTitle,
                                style: KivetoText.pageTitle.copyWith(
                                  height: 1.15,
                                ),
                              ),
                            ),
                            const SizedBox(height: KivetoSpace.xl4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: KivetoTextField(
                                    label: l10n.identityFirstNameLabel,
                                    controller: _firstName,
                                    errorText: _fieldErrors['firstName'],
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.givenName,
                                    ],
                                    onChanged: (_) => _edited('firstName'),
                                  ),
                                ),
                                const SizedBox(width: KivetoSpace.ml),
                                Expanded(
                                  child: KivetoTextField(
                                    label: l10n.identityLastNameLabel,
                                    controller: _lastName,
                                    errorText: _fieldErrors['lastName'],
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.familyName,
                                    ],
                                    onChanged: (_) => _edited('lastName'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: KivetoSpace.xl),
                            KivetoTextField(
                              label: l10n.identityEmailLabel,
                              controller: _email,
                              helpText: l10n.identityRegisterEmailHelp,
                              errorText: _fieldErrors['email'],
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.email],
                              onChanged: (_) => _edited('email'),
                            ),
                            const SizedBox(height: KivetoSpace.xl),
                            TermsConsent(
                              value: _accepted,
                              onChanged: (value) =>
                                  setState(() => _accepted = value),
                            ),
                            const SizedBox(height: KivetoSpace.xl4),
                            Text(
                              l10n.identityRegisterNote,
                              style: KivetoText.bodySmall.copyWith(
                                height: 1.45,
                              ),
                            ),
                            if (error != null) ...[
                              const SizedBox(height: KivetoSpace.xl),
                              Semantics(
                                liveRegion: true,
                                child: KivetoCallout.danger(
                                  body: error,
                                  actionLabel: _restartable
                                      ? l10n.identityRestart
                                      : null,
                                  onAction: _restartable ? _restart : null,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: KivetoSpace.xl5),
                        KivetoButton.primary(
                          label: l10n.identityRegisterSubmit,
                          loading: _sending,
                          onPressed: ready ? () => unawaited(_submit()) : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
