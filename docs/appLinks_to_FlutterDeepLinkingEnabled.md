# Deep Links Migration Walkthrough

This document outlines the changes made to migrate the deep linking architecture from `app_links` to Flutter's native `FlutterDeepLinkingEnabled` using the `go_router` package, specifically targeting iOS based on the user's request.

## Changes Made

### 1. Dependency Updates
- Removed the `app_links` package from the project.
- Integrated the `go_router` package (version 17.1.0) to handle incoming routing paths automatically instead of manually listening to stream events.

### 2. iOS Native Configuration
- Updated [Info.plist](/ios/Runner/Info.plist) directly to include `<key>FlutterDeepLinkingEnabled</key><true/>`.
- This ensures that iOS will route deep links straight into the native Flutter engine which `go_router` binds to.

### 3. Application Refactoring
- **App Entry (`MainApp`)**: Refactored `MaterialApp` to `MaterialApp.router` alongside a top-level `_router` configuration handling the root path (`/`).
- **Routing Interception**: 
  - Sub-paths are gracefully caught by standard error builder / default routes allowing the router URI string to be explicitly forwarded to the user interface.
- **HomeScreen Adjustments**: 
  - Deprecated and removed initialization states (`_initDeepLinks`), stream watchers (`_linkSubscription`), and dependency initializers. 
  - Made the deep link reactive to Flutter widget lifecycle mechanisms by directly reading `currentLink` passed down from `GoRoute`'s `state.uri.toString()`. 

render_diffs(/lib/main.dart)

## Verification and Validation

### Static Analysis
A full static analysis was run on the `lib` folder. No errors or warnings were generated:
```shell
flutter analyze lib
# Output: No issues found! (ran in 4.7s)
```

*(Note: Test directories were automatically skipped for this minimal PoC as they do not exist)*

### Manual Testing Recommendations
As this is a Universal Links setup, please test on a physical iOS device by:
1. Sending the target link configuration format to yourself via iMessage or Notes.
2. Clicking the link and verifying it successfully opens the app.
3. Checking the UI screen to ensure "Latest Received Link" points to the exact path.
