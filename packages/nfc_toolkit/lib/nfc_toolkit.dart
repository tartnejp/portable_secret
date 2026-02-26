library nfc_toolkit;

// Core
export 'src/core/nfc_detection.dart';
export 'src/nfc_data.dart';
export 'src/nfc_service.dart';
// Providers
export 'src/providers/nfc_detection_registry.dart';
export 'src/riverpod/nfc_providers.dart';
export 'src/state/nfc_debug_log.dart';
export 'src/state/nfc_detection_provider.dart';
export 'src/state/nfc_error_handler.dart';
export 'src/state/nfc_generic_handler.dart';
export 'src/state/nfc_interest_registry.dart';
export 'src/state/nfc_session.dart';
// UI
export 'src/ui/nfc_detection_scope.dart';
export 'src/ui/nfc_session_trigger_widget.dart';

// Deprecated / Internal logic (Keeping for now if needed, but not recommended)
// export 'src/logic/nfc_action.dart';
// export 'src/logic/nfc_action_selector.dart';
