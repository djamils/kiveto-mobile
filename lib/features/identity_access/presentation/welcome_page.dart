import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/identity_access/di.dart';
import 'package:kiveto_mobile/features/identity_access/domain/phone_number.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/country_code_sheet.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/flows.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/identity_messages.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/invitation_link_sheet.dart';
import 'package:kiveto_mobile/features/identity_access/presentation/phone_input_formatter.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/surfaces.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// Screen 7, Bienvenue: the mobile number, the code sent by SMS
/// (`POST /auth/otp/request`), the invitation box.
///
/// Exits: [onCodeSent] once the code is sent (the flow holds the number
/// and the challenge), [onInvitationLink] with the token of a pasted
/// invitation link, [onKitGallery] (debug builds only).
class WelcomePage extends ConsumerStatefulWidget {
  const new({
    required this.onCodeSent,
    required this.onInvitationLink,
    super.key,
    this.onKitGallery,
  });

  final void Function(BuildContext context) onCodeSent;
  final void Function(BuildContext context, String token) onInvitationLink;
  final void Function(BuildContext context)? onKitGallery;

  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  final _phone = TextEditingController();
  PhoneCountry _country = PhoneCountry.france;
  String? _error;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Back from the code page ("Modifier"): the number is kept.
    final flow = ref.read(signInFlowProvider);
    if (flow != null) {
      _country = PhoneCountry.all.firstWhere(
        (country) => country.code == flow.phone.countryCode,
        orElse: () => PhoneCountry.france,
      );
      _phone.text = PhoneInputFormatter.format(
        flow.phone.national,
        tenDigitPlan: _country.tenDigitPlan,
      );
    }
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  bool get _complete => _country.isComplete(_phone.text);

  Future<void> _pickCountry() async {
    final picked = await showCountryCodeSheet(context, selected: _country);
    if (picked == null || !mounted) return;
    final text = PhoneInputFormatter.format(
      _phone.text,
      tenDigitPlan: picked.tenDigitPlan,
    );
    setState(() {
      _country = picked;
      _error = null;
      _phone.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  Future<void> _openInvitationLink() async {
    final token = await showInvitationLinkSheet(context);
    if (token == null || !mounted) return;
    widget.onInvitationLink(context, token);
  }

  Future<void> _submit() async {
    final phone = PhoneNumber.fromNational(
      countryCode: _country.code,
      national: _phone.text,
    );
    if (phone == null || _sending || !_complete) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final challenge = await ref
          .read(authRepositoryProvider)
          .requestCode(phone);
      if (!mounted) return;
      ref.read(signInFlowProvider.notifier).start(phone, challenge);
      setState(() => _sending = false);
      widget.onCodeSent(context);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = error is ValidationFailure
            ? l10n.identityErrorPhoneInvalid
            : identityErrorText(l10n, error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onKitGallery = widget.onKitGallery;
    return Scaffold(
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
                    KivetoSpace.xl7,
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
                          const Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: KivetoBrandLockup(),
                          ),
                          const SizedBox(height: KivetoSpace.xl7),
                          Semantics(
                            header: true,
                            child: Text(
                              l10n.identityWelcomeTitle,
                              style: KivetoText.display,
                            ),
                          ),
                          const SizedBox(height: KivetoSpace.m),
                          Text(
                            l10n.identityWelcomeIntro,
                            style: KivetoText.bodyLarge,
                          ),
                          const SizedBox(height: KivetoSpace.xl7),
                          KivetoPhoneField(
                            label: l10n.identityPhoneLabel,
                            controller: _phone,
                            countryCode: _country.code,
                            onCountryTap: () => unawaited(_pickCountry()),
                            hintText: l10n.identityPhoneHint,
                            helpText: l10n.identityPhoneHelp,
                            errorText: _error,
                            inputFormatters: [
                              PhoneInputFormatter(
                                tenDigitPlan: _country.tenDigitPlan,
                                countryCode: _country.code,
                              ),
                            ],
                            onChanged: (_) => setState(() => _error = null),
                            onSubmitted: (_) => unawaited(_submit()),
                          ),
                          const SizedBox(height: KivetoSpace.l),
                          KivetoButton.primary(
                            label: l10n.identityRequestCode,
                            loading: _sending,
                            onPressed: _complete
                                ? () => unawaited(_submit())
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: KivetoSpace.xl5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          KivetoCallout.info(
                            title: l10n.identityInvitationBoxTitle,
                            body: l10n.identityInvitationBoxBody,
                            actionLabel: l10n.identityInvitationBoxAction,
                            onAction: () => unawaited(_openInvitationLink()),
                          ),
                          if (onKitGallery != null) ...[
                            const SizedBox(height: KivetoSpace.sm),
                            KivetoTextButton(
                              label: l10n.welcomeKitGalleryLink,
                              onPressed: () => onKitGallery(context),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
