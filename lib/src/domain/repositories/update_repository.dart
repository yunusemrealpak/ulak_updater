import 'package:fpdart/fpdart.dart';

import '../entities/release_info.dart';
import '../failures/update_failure.dart';

/// Abstract repository — domain depends on this; data layer provides the
/// implementation. Returns Either for explicit failure paths.
abstract class UpdateRepository {
  /// Fetch the currently published release for the configured channel.
  Future<Either<UpdateFailure, ReleaseInfo>> getCurrentRelease();

  /// Download the APK to a local file. Streams progress through [onProgress].
  /// On success returns the absolute file path.
  Future<Either<UpdateFailure, String>> downloadApk({
    required ReleaseInfo info,
    required void Function(int received, int total) onProgress,
  });

  /// Verify the SHA-256 of [filePath] against [expectedSha256].
  Future<Either<UpdateFailure, Unit>> verifyApk({
    required String filePath,
    required String expectedSha256,
  });

  /// Trigger Android PackageInstaller flow. Caller's process will be killed
  /// by the system on success; the returned Future resolves only on early
  /// failure (permission denied, intent unavailable, etc.).
  Future<Either<UpdateFailure, Unit>> installApk(String filePath);

  /// Anonymous checkin: tells the server which versionCode this device is on.
  /// Fire-and-forget; failures are logged but do not block the UI.
  Future<void> sendCheckin({
    required int currentVersionCode,
    required String currentVersionName,
  });

  /// Get the device's persistent UUID (creating one on first use).
  Future<String> getDeviceUuid();
}
