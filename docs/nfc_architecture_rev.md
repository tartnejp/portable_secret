# NFC Architecture & Implementation Details (Application Integration Revision)

This document outlines the current design of the `nfc_toolkit` and how it is integrated into the `portable_sec` application. This architecture emphasizes type safety, loose coupling, and flexible UI handling.

## 1. Core Concepts

The architecture is built around the **Event Stream** pattern.
1.  **NFC Data Stream**: The toolkit listens to the raw NFC stream from the OS.
2.  **Detection & Transformation**: Raw data is passed through a list of registered "Detectors" (`NfcDetection`).
3.  **Event Broadcasting**: Successful detections are broadcasted via a Riverpod stream (`nfcDetectionStreamProvider`).
4.  **UI consumption**: The UI listens to this stream to perform actions (Navigation, Overlay, etc.).

## 2. Toolkit Logic (packages/nfc_toolkit)

### 2.1. `NfcDetection` (The Base Class)
`NfcDetection` is the base class for all specific detection types. It represents **Logic** (how to detect it) and **Data** (what was detected).

```dart
abstract class NfcDetection {
  /// Analyzes raw NFC data and returns a new instance of itself (populated) if successful.
  FutureOr<NfcDetection?> detect(NfcData data);
}
```

### 2.2. `OverlayDisplay` (Mixin)
This mixin marks a detection as something that should trigger a **Global Overlay**. If a detection class mixes this in, `NfcDetectionScope` will automatically show a toast message.

```dart
mixin OverlayDisplay on NfcDetection {
  String get overlayMessage;
}
```

### 2.3. `NfcDetectionRegistry` (Configuration)
The toolkit is agnostic of specific app logic. The app must provide a registry of supported detections.

```dart
final nfcDetectionRegistryProvider = Provider<NfcDetectionRegistry>((ref) {
  throw UnimplementedError('Must be overridden by app');
});
```

### 2.4. `nfcDetectionStreamProvider` (The Engine)
This is the heart of the logic. It watches the registry and the raw NFC stream.
- When a tag is touched:
    1.  It instantiates all registered detectors.
    2.  Runs `detect()` on all of them in parallel.
    3.  Yields any successful matches.
    4.  If nothing matches, yields `GenericNfcDetected` (fallback).

### 2.5. `NfcDetectionScope` (Visual Layer)
A wrapper widget typically placed at the root (or high up) of the widget tree.
- Listens to `nfcDetectionStreamProvider`.
- If an event implements `OverlayDisplay`, it adds the message to a queue and displays it.
- **Note**: It does NOT handle navigation. Navigation is the responsibility of individual screens.

### 2.6. `listenNfcDetection` (Helper Extension)
A utility to make listening easier and type-safe in the UI.

```dart
ref.listenNfcDetection<SecretDetection>((detection) {
  // Logic to handle specific detection
});
```

---

## 3. Application Integration (portable_sec)

### 3.1. Defining Detections
The app defines specific detection logic.

- **`SecretDetection`**:
    - **Logic**: parsed encrypted data from the tag.
    - **UI**: Does **NOT** mix in `OverlayDisplay`. This is by design.
    - **Reason**: We do not want a global overlay for secrets; we want specific screens (Home) to handle it and navigate separately. Non-Home screens should ignore it.

- **`UrlDetection`**:
    - **Logic**: Parses NDEF URL records.
    - **UI**: Mixes in `OverlayDisplay`.
    - **Reason**: Useful for debugging or generic reading. Shows "URL Detected: ..." anywhere in the app.

### 3.2. Registration (`main.dart`)
The detections are registered at the app root.

```dart
ProviderScope(
  overrides: [
    NfcDetectionRegistryProvider.overrideWithValue(
      NfcDetectionRegistry([
        () => const SecretDetection(),
        () => const UrlDetection(),
      ]),
    ),
  ],
  child: MyApp(),
)
```

### 3.3. Usage in UI (`HomeScreen`)
The `HomeScreen` specifically listens for `SecretDetection` to trigger navigation.

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen for Secret Detection
    ref.listenNfcDetection<SecretDetection>((detection) {
        // Handle navigation logic here
        // Because "SecretDetection" does not have OverlayDisplay,
        // no overlay is shown by the scope. The screen handles the feedback (transition).
    });

    // 2. Listen for Generic/Unknown tags
    ref.listenNfcDetection<GenericNfcDetected>((detection) {
        // Show local feedback or rely on global GenericNfcDetected overlay
    });

    return Scaffold(...);
  }
}
```

## 4. Summary of Flow

| Scenario | Detection Type | Global Overlay? | Home Screen | Other Screens |
| :--- | :--- | :--- | :--- | :--- |
| **Unknown Tag** | `GenericNfcDetected` | **YES** | Shows Overlay | Shows Overlay |
| **URL Tag** | `UrlDetection` | **YES** | Shows Overlay | Shows Overlay |
| **Secret Tag** | `SecretDetection` | **NO** | **Navigates to Unlock** | **Ignores** |

This design ensures:
1.  **Separation of Concerns**: Toolkit handles NFC reading; App handles Business Logic.
2.  **Flexibility**: Some tags show generic overlays globally; others trigger specific actions on specific screens.
3.  **Safety**: No unexpected navigation from screens that aren't listening.
