import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nfc_toolkit_method_channel.dart';

abstract class NfcToolkitPlatform extends PlatformInterface {
  /// Constructs a NfcToolkitPlatform.
  NfcToolkitPlatform() : super(token: _token);

  static final Object _token = Object();

  static NfcToolkitPlatform _instance = MethodChannelNfcToolkit();

  /// The default instance of [NfcToolkitPlatform] to use.
  ///
  /// Defaults to [MethodChannelNfcToolkit].
  static NfcToolkitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NfcToolkitPlatform] when
  /// they register themselves.
  static set instance(NfcToolkitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
