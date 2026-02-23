library nfc_toolkit;

export 'src/nfc_data.dart';
export 'src/ui/nfc_session_trigger_widget.dart';
export 'src/nfc_service.dart';
export 'src/riverpod/nfc_providers.dart';

// Core
export 'src/core/nfc_detection.dart';

// Providers
export 'src/providers/nfc_detection_registry.dart';
export 'src/state/nfc_detection_provider.dart';
export 'src/state/nfc_session.dart';
export 'src/state/nfc_interest_registry.dart';
export 'src/state/nfc_generic_handler.dart';
export 'src/state/nfc_debug_log.dart';

// UI
export 'src/ui/nfc_detection_scope.dart';

// Deprecated / Internal logic (Keeping for now if needed, but not recommended)
// export 'src/logic/nfc_action.dart';
// export 'src/logic/nfc_action_selector.dart';
