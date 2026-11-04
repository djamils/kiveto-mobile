// The public API of identity_access: the sign-in, invitation and
// registration pages (their exits are callbacks: the feature never imports
// app/), the logout (`ref.read(signOutProvider)()`), and the account
// changes a code by SMS confirms: the e-mail change and the deletion
// sheets.

export 'package:kiveto_mobile/features/identity_access/di.dart'
    show signOutProvider;
export 'package:kiveto_mobile/features/identity_access/presentation/account_deletion_sheet.dart'
    show showAccountDeletionSheet;
export 'package:kiveto_mobile/features/identity_access/presentation/code_page.dart';
export 'package:kiveto_mobile/features/identity_access/presentation/email_change_sheet.dart'
    show showEmailChangeSheet;
export 'package:kiveto_mobile/features/identity_access/presentation/invitation_page.dart';
export 'package:kiveto_mobile/features/identity_access/presentation/onboarding_invitations_page.dart';
export 'package:kiveto_mobile/features/identity_access/presentation/register_page.dart';
export 'package:kiveto_mobile/features/identity_access/presentation/welcome_page.dart';
