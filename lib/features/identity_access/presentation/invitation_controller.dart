import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiveto_mobile/features/identity_access/di.dart';
import 'package:kiveto_mobile/features/identity_access/domain/invitation_preview.dart';
import 'package:kiveto_mobile/features/identity_access/domain/otp_challenge.dart';
import 'package:kiveto_mobile/shared/domain/api_failure.dart';

/// Why an invitation link cannot be used.
enum InvitationClosedReason { expired, invalid, used }

/// The state of screen 0.
sealed class InvitationState {
  const new();
}

/// The link is being read.
final class InvitationLoading extends InvitationState {
  const new();
}

/// The link cannot be used: expired, unknown or replaced, already used.
final class InvitationClosed extends InvitationState {
  const new(this.reason);

  final InvitationClosedReason reason;
}

/// The link could not be read (network, server): retry.
final class InvitationLoadFailed extends InvitationState {
  const new(this.error);

  final Object error;
}

/// The invitation, its code challenge once sent, and the outcome of the
/// last code request and acceptance.
final class InvitationReady extends InvitationState {
  const new({
    required this.preview,
    this.challenge,
    this.sendingCode = false,
    this.codeError,
    this.resent = false,
    this.accepting = false,
    this.acceptError,
  });

  final InvitationPreview preview;
  final OtpChallenge? challenge;
  final bool sendingCode;

  /// The last code request failed (a quota…): shown with the resend
  /// control.
  final Object? codeError;

  /// A new code was sent on request.
  final bool resent;
  final bool accepting;

  /// The last acceptance was refused.
  final Object? acceptError;

  static const _keep = Object();

  InvitationReady copyWith({
    OtpChallenge? challenge,
    bool? sendingCode,
    Object? codeError = _keep,
    bool? resent,
    bool? accepting,
    Object? acceptError = _keep,
  }) => InvitationReady(
    preview: preview,
    challenge: challenge ?? this.challenge,
    sendingCode: sendingCode ?? this.sendingCode,
    codeError: identical(codeError, _keep) ? this.codeError : codeError,
    resent: resent ?? this.resent,
    accepting: accepting ?? this.accepting,
    acceptError: identical(acceptError, _keep) ? this.acceptError : acceptError,
  );
}

/// Screen 0's controller: reads the link, sends the code at once, resends
/// it, accepts the invitation (`AcceptInvitationByLink`). The link token
/// stays in this object (never in a state, a path or a log).
final NotifierProvider<InvitationController, InvitationState>
invitationControllerProvider =
    NotifierProvider.autoDispose<InvitationController, InvitationState>(
      InvitationController.new,
    );

final class InvitationController extends Notifier<InvitationState> {
  String? _token;

  @override
  InvitationState build() => const InvitationLoading();

  /// Reads the invitation of [token], then sends its code.
  Future<void> open(String token) async {
    _token = token;
    state = const InvitationLoading();
    try {
      final preview = await ref
          .read(invitationRepositoryProvider)
          .lookup(token);
      if (!ref.mounted || _token != token) return;
      state = InvitationReady(preview: preview);
    } on Object catch (error) {
      if (!ref.mounted || _token != token) return;
      state = _closedBy(error) ?? InvitationLoadFailed(error);
      return;
    }
    await _sendCode(token, resent: false);
  }

  /// Sends a new code (after the countdown, or after a failed request).
  Future<void> resend() async {
    final token = _token;
    if (token != null) await _sendCode(token, resent: true);
  }

  Future<void> _sendCode(String token, {required bool resent}) async {
    final ready = state;
    if (ready is! InvitationReady || ready.sendingCode || ready.accepting) {
      return;
    }
    state = ready.copyWith(sendingCode: true, codeError: null, resent: false);
    try {
      final challenge = await ref
          .read(invitationRepositoryProvider)
          .requestCode(token);
      // The page may have left (the state is gone), or moved on (another
      // link, a closed invitation): only a ready state takes the answer.
      if (!ref.mounted || _token != token) return;
      final current = state;
      if (current is! InvitationReady) return;
      state = current.copyWith(
        challenge: challenge,
        sendingCode: false,
        resent: resent,
      );
    } on Object catch (error) {
      if (!ref.mounted || _token != token) return;
      final current = state;
      if (current is! InvitationReady) return;
      state =
          _closedBy(error) ??
          current.copyWith(sendingCode: false, codeError: error);
    }
  }

  /// Accepts the invitation with [code] and the terms [termsVersion]; true
  /// once the session is open. A refusal is in `acceptError`, or closes
  /// the invitation. Not while a code is being sent.
  Future<bool> accept({
    required String code,
    required String termsVersion,
  }) async {
    final token = _token;
    final ready = state;
    if (token == null ||
        ready is! InvitationReady ||
        ready.accepting ||
        ready.sendingCode) {
      return false;
    }
    final challenge = ready.challenge;
    if (challenge == null) return false;
    state = ready.copyWith(accepting: true, acceptError: null);
    try {
      await ref.read(acceptInvitationByLinkProvider)(
        token: token,
        challengeId: challenge.id,
        code: code,
        termsVersion: termsVersion,
      );
      return true;
    } on Object catch (error) {
      if (!ref.mounted || _token != token) return false;
      final current = state;
      if (current is InvitationReady) {
        state =
            _closedBy(error) ??
            current.copyWith(accepting: false, acceptError: error);
      }
      return false;
    }
  }

  /// The code was edited: the refusal of the last one no longer applies.
  void clearAcceptError() {
    final ready = state;
    if (ready is InvitationReady && ready.acceptError != null) {
      state = ready.copyWith(acceptError: null);
    }
  }

  static InvitationState? _closedBy(Object error) => switch (error) {
    ApiFailure(code: 'invitation_expired') => const InvitationClosed(
      InvitationClosedReason.expired,
    ),
    ApiFailure(code: 'invitation_already_used') => const InvitationClosed(
      InvitationClosedReason.used,
    ),
    ApiFailure(code: 'invitation_invalid') => const InvitationClosed(
      InvitationClosedReason.invalid,
    ),
    _ => null,
  };
}
