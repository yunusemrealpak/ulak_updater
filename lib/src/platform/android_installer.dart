import 'package:flutter/services.dart';

/// MethodChannel bridge to the bundled Android plugin.
///
/// The plugin lives in `android/src/main/kotlin/com/tepvox/ulak_updater/UlakUpdaterPlugin.kt`
/// and is registered automatically via the `flutter.plugin` declaration in pubspec.yaml.
class AndroidInstaller {
  const AndroidInstaller();

  static const MethodChannel _channel = MethodChannel('tepvox.ulak/installer');

  /// Returns true if REQUEST_INSTALL_PACKAGES is granted (Android O+),
  /// or true on older Android (no per-app gate).
  Future<bool> canInstall() async {
    final v = await _channel.invokeMethod<bool>('canInstall');
    return v ?? false;
  }

  /// Opens the system "install unknown apps" settings page for this app.
  /// User must come back manually after granting; we re-check on resume.
  Future<void> requestInstallPermission() {
    return _channel.invokeMethod<void>('requestInstallPermission');
  }

  /// Launches Android's PackageInstaller via FileProvider intent. On success
  /// the system dialog appears; if the user accepts, our process is killed
  /// when the new APK is committed. This Future resolves only on early failure.
  Future<void> installApk(String filePath) {
    return _channel.invokeMethod<void>('installApk', {'path': filePath});
  }
}
