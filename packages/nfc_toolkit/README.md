# nfc_toolkit

A Flutter package that provides a high-level API for NFC interactions, building upon `nfc_manager`. It simplifies commonly used patterns such as "Touch to Start", "Session Management", and "NDEF Record Parsing".

## Features
- **Simplified API**: Abstract complex NFC session management.
- **Detector**: `NfcDetectionScope` to globally listen for tags and handle side effects (overlays).
- **Hybrid Architecture**: Support for both "Passive" (overlay) and "Active" (route-aware) detection strategies.

## Installation

### 1. Add dependency
Recommended approach is to use a Git dependency if you are keeping this package in a private repository or a monorepo.

**pubspec.yaml**
```yaml
dependencies:
  nfc_toolkit:
     git:
       url: git://github.com/YourUser/portable_sec.git # Replace with your repo URL
       path: packages/nfc_toolkit
       ref: main # Optional: specify branch or tag
```

If you are developing locally within the same monorepo:
```yaml
dependencies:
  nfc_toolkit:
    path: ./packages/nfc_toolkit
```

## Configuration

### Android

1. **Permissions**: Add the `NFC` permission to your `android/app/src/main/AndroidManifest.xml`.
2. **Launch Mode**: Set `launchMode` to `singleTask` for your main activity. This is critical to prevent the app from restarting when an NFC tag is scanned.
3. **Intent Filter (Optional)**: Add an intent filter to launch your app when an NFC tag is detected.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.your_app">

    <uses-permission android:name="android.permission.NFC" />

    <application ...>
        <activity
            android:name=".MainActivity"
            android:launchMode="singleTask"   <!-- IMPORTANT: Prevent multiple instances -->
            android:exported="true"
            ...>
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            <!-- Optional: NDEF Discovery to open app via NFC -->
            <intent-filter>
                <action android:name="android.nfc.action.NDEF_DISCOVERED"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <data android:mimeType="application/your.mime.type"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### iOS

Add the `NFCReaderUsageDescription` key to your `ios/Runner/Info.plist`.

```xml
<key>NFCReaderUsageDescription</key>
<string>We need NFC to scan tags.</string>
```

You also need to enable the **Near Field Communication Tag Reading** capability in your Xcode project settings (Signing & Capabilities).

This will create/update your `ios/Runner/Runner.entitlements` file:
```xml
<dict>
    <key>com.apple.developer.nfc.readersession.formats</key>
    <array>
        <string>NDEF</string>
        <string>TAG</string>
    </array>
</dict>
```

## Usage

### 1. Define your Detectors

Create classes that extend `NfcDetection`. If you want the detection to trigger an overlay automatically, mix in `OverlayDisplay`.

```dart
import 'package:nfc_toolkit/nfc_toolkit.dart';

// Example: Detects a specific "Secret" tag
class SecretDetection extends NfcDetection with OverlayDisplay {
  final String secretId;

  const SecretDetection(this.secretId);

  @override
  String get overlayMessage => 'Secret Found!';

  @override
  FutureOr<NfcDetection?> detect(NfcData data) {
    // Implement your logic to check if this is a "Secret" tag
    // For example, check payload, identifier, etc.
    if (data.identifier.isNotEmpty) { // Simplified check
       return SecretDetection(data.identifier);
    }
    return null;
  }
}

// Example: Detects a URL (Active Routing)
class UrlDetection extends NfcDetection {
  final Uri url;
  const UrlDetection(this.url);

  @override
  FutureOr<NfcDetection?> detect(NfcData data) async {
    // Parse NDEF records to find a URL
    // ... implementation ...
    return null;
  }
}
```

### 2. Register Detectors

In your `main.dart`, override the `nfcDetectionRegistryProvider` within the `ProviderScope`. This tells the toolkit which detectors to run when a tag is scanned.

```dart
void main() {
  runApp(
    ProviderScope(
      overrides: [
        nfcDetectionRegistryProvider.overrideWithValue(
          NfcDetectionRegistry([
            () => const SecretDetection(''), // Pass a factory/prototype
            () => const UrlDetection(Uri()),
          ]),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

### 3. Setup `NfcDetectionScope`

Wrap your application (or a sub-tree) with `NfcDetectionScope`. This widget listens to the global NFC stream and handles the UI overlay for `OverlayDisplay` events.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NfcDetectionScope(
        // Optional: Provide a way to get the current route name for filtering
        routeNameGetter: (context) => ModalRoute.of(context)?.settings.name,
        
        // Optional: Disable the generic "NFC Tag Detected" overlay on specific routes
        disableGenericDetectionRoutes: {'/home'},

        // Optional: Suppress specific detection types on specific routes
        routeDetectionSuppressions: {
          '/secret_view': [SecretDetection],
        },
        
        child: const HomePage(),
      ),
    );
  }
}
```

### 4. Listen for Events

Use the `listenNfcDetection` extension on `ref` (in `ConsumerWidget` or providers) to react to specific detections (e.g., navigation).

```dart
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for SecretDetection events
    ref.listenNfcDetection<SecretDetection>((detection) {
      // Navigate to secret view
      Navigator.of(context).pushNamed('/secret', arguments: detection.secretId);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Scan a tag')),
    );
  }
}
```
