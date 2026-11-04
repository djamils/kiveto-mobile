import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/client/di.dart';
import 'package:kiveto_mobile/features/client/domain/me.dart';
import 'package:kiveto_mobile/features/client/domain/profile_update.dart';
import 'package:kiveto_mobile/features/client/presentation/client_providers.dart';
import 'package:kiveto_mobile/l10n/app_localizations.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';
import 'package:kiveto_mobile/shared/presentation/async/async_views.dart';
import 'package:kiveto_mobile/shared/presentation/kit/buttons.dart';
import 'package:kiveto_mobile/shared/presentation/kit/feedback.dart';
import 'package:kiveto_mobile/shared/presentation/kit/forms.dart';
import 'package:kiveto_mobile/shared/presentation/kit/navigation.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_colors.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_layout.dart';
import 'package:kiveto_mobile/shared/presentation/tokens/kiveto_text.dart';
import 'package:material_ui/material_ui.dart';

/// The profile form of the account screen (6), in a sheet: the names and
/// the postal address, sent as a merge patch (`PATCH /me`); the server
/// checks every value. True once saved (`GET /me` then reloads).
Future<bool> showProfileEditSheet(
  BuildContext context,
  Account account,
) async =>
    await showKivetoSheet<bool>(
      context: context,
      builder: (context) => ProfileEditSheet(account: account),
    ) ??
    false;

/// The content of the profile sheet (see [showProfileEditSheet]).
class ProfileEditSheet extends ConsumerStatefulWidget {
  const new({required this.account, super.key});

  final Account account;

  @override
  ConsumerState<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

/// The fields of the form, by the `propertyPath` the server names them.
enum _Field { firstName, lastName, street, postalCode, city }

class _ProfileEditSheetState extends ConsumerState<ProfileEditSheet> {
  late final Map<_Field, TextEditingController> _fields = () {
    final account = widget.account;
    final address = account.address;
    return {
      _Field.firstName: TextEditingController(text: account.firstName ?? ''),
      _Field.lastName: TextEditingController(text: account.lastName ?? ''),
      // The API takes one street line: a second line is kept in it.
      _Field.street: TextEditingController(
        text: [
          ?address?.line1,
          if (address?.line2 case final line2? when line2.trim().isNotEmpty)
            line2,
        ].join(', '),
      ),
      _Field.postalCode: TextEditingController(text: address?.postalCode ?? ''),
      _Field.city: TextEditingController(text: address?.city ?? ''),
    };
  }();
  bool _saving = false;
  Map<_Field, String> _errors = const {};
  String? _formError;

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _text(_Field field) => _fields[field]!.text;

  static _Field? _fieldOf(String propertyPath) => switch (propertyPath) {
    'firstName' => _Field.firstName,
    'lastName' => _Field.lastName,
    'address.streetLine1' => _Field.street,
    'address.postalCode' => _Field.postalCode,
    'address.city' => _Field.city,
    _ => null,
  };

  static String _errorOf(AppLocalizations l10n, _Field field) =>
      switch (field) {
        _Field.firstName => l10n.accountProfileFirstNameError,
        _Field.lastName => l10n.accountProfileLastNameError,
        _Field.street => l10n.accountProfileStreetError,
        _Field.postalCode => l10n.accountProfilePostalCodeError,
        _Field.city => l10n.accountProfileCityError,
      };

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    final update = ProfileUpdate.fromForm(
      firstName: _text(_Field.firstName),
      lastName: _text(_Field.lastName),
      streetLine1: _text(_Field.street),
      postalCode: _text(_Field.postalCode),
      city: _text(_Field.city),
      currentCountry: widget.account.address?.country,
    );
    // Saved whatever became of the sheet: the account reloads.
    final container = ProviderScope.containerOf(context, listen: false);
    setState(() {
      _saving = true;
      _errors = const {};
      _formError = null;
    });
    try {
      await ref.read(meRepositoryProvider).updateProfile(update);
      container.invalidate(meProvider);
      // Closed meanwhile (the sheet may still be animating out): nothing
      // to pop, or the page under it would go.
      if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
      Navigator.of(context).pop(true);
    } on Object catch (error) {
      if (!mounted) return;
      final errors = <_Field, String>{};
      String? formError;
      if (error case ValidationFailure(:final violations)) {
        for (final violation in violations) {
          final field = _fieldOf(violation.propertyPath);
          if (field == null) {
            formError = l10n.errorValidationBody;
          } else {
            errors[field] = _errorOf(l10n, field);
          }
        }
        if (violations.isEmpty) formError = l10n.errorValidationBody;
      } else {
        formError = failureMessage(l10n, error).$2;
      }
      setState(() {
        _saving = false;
        _errors = errors;
        _formError = formError;
      });
    }
  }

  Widget _field(
    AppLocalizations l10n,
    _Field field,
    String label, {
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    bool last = false,
  }) => KivetoTextField(
    label: label,
    controller: _fields[field],
    errorText: _errors[field],
    enabled: !_saving,
    keyboardType: keyboardType,
    textInputAction: last ? TextInputAction.done : TextInputAction.next,
    onSubmitted: last ? (_) => unawaited(_save()) : null,
    autofillHints: autofillHints,
    onChanged: (_) {
      if (_errors.containsKey(field)) {
        setState(() => _errors = {..._errors}..remove(field));
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formError = _formError;
    // The names and the address filled together by the platform.
    return AutofillGroup(
      child: KivetoSheet(
        title: l10n.accountProfileSheetTitle,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _field(
                  l10n,
                  _Field.firstName,
                  l10n.accountProfileFirstName,
                  autofillHints: const [AutofillHints.givenName],
                ),
              ),
              const SizedBox(width: KivetoSpace.ml),
              Expanded(
                child: _field(
                  l10n,
                  _Field.lastName,
                  l10n.accountProfileLastName,
                  autofillHints: const [AutofillHints.familyName],
                ),
              ),
            ],
          ),
          const SizedBox(height: KivetoSpace.sm),
          _field(
            l10n,
            _Field.street,
            l10n.accountProfileStreet,
            keyboardType: TextInputType.streetAddress,
            autofillHints: const [AutofillHints.streetAddressLine1],
          ),
          const SizedBox(height: KivetoSpace.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _field(
                  l10n,
                  _Field.postalCode,
                  l10n.accountProfilePostalCode,
                  autofillHints: const [AutofillHints.postalCode],
                ),
              ),
              const SizedBox(width: KivetoSpace.ml),
              Expanded(
                flex: 3,
                child: _field(
                  l10n,
                  _Field.city,
                  l10n.accountProfileCity,
                  autofillHints: const [AutofillHints.addressCity],
                  last: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: KivetoSpace.xs),
          KivetoFootnote(l10n.accountProfileFootnote),
          if (formError != null) ...[
            const SizedBox(height: KivetoSpace.xs),
            Semantics(
              liveRegion: true,
              child: Text(
                formError,
                style: KivetoText.bodySmall.copyWith(
                  color: KivetoColors.danger,
                ),
              ),
            ),
          ],
          const SizedBox(height: KivetoSpace.xs),
          KivetoButton.primary(
            label: l10n.accountProfileSave,
            loading: _saving,
            onPressed: () => unawaited(_save()),
          ),
        ],
      ),
    );
  }
}
