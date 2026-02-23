import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the action to take after an NFC session is processed by the UI.
class NfcSessionAction {
  final bool isSuccess;
  final String? message;
  final bool isNone;
  final void Function()? onComplete;

  const NfcSessionAction._({
    required this.isSuccess,
    this.message,
    this.isNone = false,
    this.onComplete,
  });

  /// The UI successfully processed the tag.
  /// [message] will be displayed as a success message on iOS, or as an overlay on Android.
  factory NfcSessionAction.success({
    String? message,
    void Function()? onComplete,
  }) {
    return NfcSessionAction._(
      isSuccess: true,
      message: message,
      onComplete: onComplete,
    );
  }

  /// The UI encountered an error while processing the tag.
  /// [message] will be displayed as an error message on iOS, or as an error overlay on Android.
  factory NfcSessionAction.error({
    required String message,
    void Function()? onComplete,
  }) {
    return NfcSessionAction._(
      isSuccess: false,
      message: message,
      onComplete: onComplete,
    );
  }

  /// The UI processed the tag but no specific action is required.
  /// This closes the session with a default message if possible.
  factory NfcSessionAction.none({void Function()? onComplete}) {
    return NfcSessionAction._(
      isSuccess: true,
      isNone: true,
      onComplete: onComplete,
    );
  }
}

/// The state of the current NFC Session.
enum NfcSessionState {
  /// Session is active, scanning for tags, but no UI has claimed it yet.
  idle,

  /// A tag has been detected and a UI component has claimed ownership for processing.
  claimed,
}

/// Controls the lifecycle and ownership of an active NFC session.
///
/// This controller bridges the gap between passive `ref.listen` components and
/// the active, stateful iOS NFC sheet. When a UI listens to an NFC event,
/// it can `takeOwnership()` of this session, preventing the system from automatically
/// closing the native NFC reader while asynchronous work (like API calls) is performed.
class NfcSessionController extends Notifier<NfcSessionState> {
  @override
  NfcSessionState build() {
    return NfcSessionState.idle;
  }

  /// Claims ownership of the current session.
  ///
  /// This must be called immediately when a UI component starts processing a tag.
  /// Once claimed, `GenericDetection` fallbacks will be suppressed.
  ///
  /// Returns `true` if ownership was successfully claimed (or was already claimed).
  bool takeOwnership() {
    if (state == NfcSessionState.idle) {
      state = NfcSessionState.claimed;
      return true;
    }
    // Already claimed.
    return false;
  }

  /// Resets the session back to idle.
  void releaseOwnership() {
    state = NfcSessionState.idle;
  }

  /// Checks if the session is currently claimed.
  bool get isClaimed => state == NfcSessionState.claimed;
}

/// Provider for the [NfcSessionController].
final nfcSessionControllerProvider =
    NotifierProvider<NfcSessionController, NfcSessionState>(() {
      return NfcSessionController();
    });
