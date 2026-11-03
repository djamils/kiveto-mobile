import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/core/di/core_providers.dart';
import 'package:kiveto_mobile/features/identity_access/application/accept_invitation_by_link.dart';
import 'package:kiveto_mobile/features/identity_access/application/accept_pending_invitation.dart';
import 'package:kiveto_mobile/features/identity_access/application/register_account.dart';
import 'package:kiveto_mobile/features/identity_access/application/sign_in_with_code.dart';
import 'package:kiveto_mobile/features/identity_access/application/sign_out.dart';
import 'package:kiveto_mobile/features/identity_access/domain/auth_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/invitation_repository.dart';
import 'package:kiveto_mobile/features/identity_access/domain/session_store.dart';
import 'package:kiveto_mobile/features/identity_access/domain/terms_repository.dart';
import 'package:kiveto_mobile/features/identity_access/infrastructure/portal_auth_repository.dart';
import 'package:kiveto_mobile/features/identity_access/infrastructure/portal_invitation_repository.dart';
import 'package:kiveto_mobile/features/identity_access/infrastructure/portal_terms_repository.dart';
import 'package:kiveto_mobile/features/identity_access/infrastructure/session_manager_store.dart';

// The bindings of identity_access: its contracts on the Portal API and the
// app's session, and its use cases. The presentation reads the
// repositories directly for what only reads or sends (no pass-through use
// case: code request and resend, invitation lookup and code, terms).

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => PortalAuthRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);

final invitationRepositoryProvider = Provider<InvitationRepository>(
  (ref) => PortalInvitationRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);

final termsRepositoryProvider = Provider<TermsRepository>(
  (ref) => PortalTermsRepository(
    ref.watch(portalServerProvider),
    ref.watch(apiFailureMapperProvider),
  ),
);

final sessionStoreProvider = Provider<SessionStore>(
  (ref) => SessionManagerStore(ref.watch(sessionManagerProvider)),
);

final signInWithCodeProvider = Provider<SignInWithCode>(
  (ref) => SignInWithCode(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionStoreProvider),
  ),
);

final acceptInvitationByLinkProvider = Provider<AcceptInvitationByLink>(
  (ref) => AcceptInvitationByLink(
    ref.watch(invitationRepositoryProvider),
    ref.watch(sessionStoreProvider),
  ),
);

final acceptPendingInvitationProvider = Provider<AcceptPendingInvitation>(
  (ref) => AcceptPendingInvitation(
    ref.watch(invitationRepositoryProvider),
    ref.watch(sessionStoreProvider),
  ),
);

final registerAccountProvider = Provider<RegisterAccount>(
  (ref) => RegisterAccount(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionStoreProvider),
  ),
);

/// The logout: `ref.read(signOutProvider)()`.
final signOutProvider = Provider<SignOut>(
  (ref) => SignOut(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionStoreProvider),
  ),
);
