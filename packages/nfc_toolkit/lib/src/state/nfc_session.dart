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
