import 'package:equatable/equatable.dart';

/// A release as advertised by the ulak server, mapped to a domain entity.
///
/// Returned from `/v1/version` and consumed by the update flow to decide
/// whether the device needs to update, where to download the APK from,
/// and how to verify it.
class ReleaseInfo extends Equatable {
  /// Creates a [ReleaseInfo]. All fields are required.
  const ReleaseInfo({
    required this.versionCode,
    required this.versionName,
    required this.sha256,
    required this.fileSize,
    required this.downloadUrl,
    required this.mandatory,
    required this.releaseNotes,
    required this.publishedAt,
  });

  /// Monotonically increasing integer (Android `versionCode`). The update
  /// engine compares the device's `versionCode` against this strictly with
  /// `<`; equal or greater means "up to date".
  final int versionCode;

  /// Human-readable SemVer string (e.g. `1.4.3`). Shown in dialogs.
  final String versionName;

  /// Lowercase hex-encoded SHA-256 of the APK. Verified after download
  /// before the install intent is dispatched.
  final String sha256;

  /// Size of the APK in bytes. Used to render download progress.
  final int fileSize;

  /// Pre-signed URL the device should GET to fetch the APK.
  final String downloadUrl;

  /// When `true`, the host app must update before it can proceed; the
  /// update flow shows a fullscreen blocker. When `false`, the user may
  /// defer.
  final bool mandatory;

  /// Markdown / plain-text release notes shown to the user.
  final String releaseNotes;

  /// Server-side publish timestamp (UTC).
  final DateTime publishedAt;

  @override
  List<Object?> get props => [
        versionCode,
        versionName,
        sha256,
        fileSize,
        downloadUrl,
        mandatory,
        releaseNotes,
        publishedAt,
      ];
}
