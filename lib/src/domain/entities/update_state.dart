import 'package:equatable/equatable.dart';

import 'release_info.dart';
import '../failures/update_failure.dart';

/// State machine values for the update flow.
///
/// Sealed so the UI can exhaustively switch on every possibility. The flow
/// proceeds roughly:
///
/// `UpdateInitial` → `UpdateChecking` →
///   ↳ `UpdateNotRequired` (terminal: host app proceeds)
///   ↳ `UpdateCheckOffline` (terminal: host app proceeds)
///   ↳ `UpdateOptional` → `UpdateDownloading` → `UpdateVerifying` →
///       `UpdateInstalling` (terminal: Android takes over)
///   ↳ `UpdateMandatory` → … (same chain, but host app is hard-blocked)
///   ↳ `UpdateFailed` (recoverable: user may retry)
sealed class UpdateState extends Equatable {
  /// Const constructor for subclasses.
  const UpdateState();

  @override
  List<Object?> get props => const [];
}

/// Initial state before any check has run. The bundled gate transitions
/// out of this immediately if `checkOnStartup` is true.
class UpdateInitial extends UpdateState {
  /// Creates an [UpdateInitial].
  const UpdateInitial();
}

/// The version check request is in flight.
class UpdateChecking extends UpdateState {
  /// Creates an [UpdateChecking].
  const UpdateChecking();
}

/// Server is unreachable (network error or timeout).
///
/// Per the soft-offline policy, the host app may proceed with the
/// currently installed version; a passive notice is shown.
class UpdateCheckOffline extends UpdateState {
  /// Creates an [UpdateCheckOffline].
  const UpdateCheckOffline();
}

/// Device is up to date; host app may render normally.
class UpdateNotRequired extends UpdateState {
  /// Creates an [UpdateNotRequired].
  const UpdateNotRequired();
}

/// A newer version exists, but is not mandatory; the user may defer.
class UpdateOptional extends UpdateState {
  /// Creates an [UpdateOptional] for the given [info].
  const UpdateOptional(this.info);

  /// The release the server is offering.
  final ReleaseInfo info;

  @override
  List<Object?> get props => [info];
}

/// A newer version exists and is mandatory; the user must update or exit.
class UpdateMandatory extends UpdateState {
  /// Creates an [UpdateMandatory] for the given [info].
  const UpdateMandatory(this.info);

  /// The release the server is forcing.
  final ReleaseInfo info;

  @override
  List<Object?> get props => [info];
}

/// APK download is in progress.
class UpdateDownloading extends UpdateState {
  /// Creates an [UpdateDownloading] snapshot.
  const UpdateDownloading({
    required this.info,
    required this.receivedBytes,
    required this.totalBytes,
  });

  /// The release being downloaded.
  final ReleaseInfo info;

  /// Bytes received so far.
  final int receivedBytes;

  /// Total bytes expected (from `Content-Length`).
  final int totalBytes;

  /// Convenience: progress in `[0.0, 1.0]`. Returns `0` until [totalBytes]
  /// is known.
  double get fraction => totalBytes <= 0 ? 0 : receivedBytes / totalBytes;

  @override
  List<Object?> get props => [info, receivedBytes, totalBytes];
}

/// Download finished; SHA-256 of the file is being computed and compared
/// against [ReleaseInfo.sha256].
class UpdateVerifying extends UpdateState {
  /// Creates an [UpdateVerifying] for the given [info].
  const UpdateVerifying(this.info);

  /// The release being verified.
  final ReleaseInfo info;

  @override
  List<Object?> get props => [info];
}

/// Verification passed; the install intent has been handed to the OS.
///
/// At this point Android shows the system "Install?" dialog and the host
/// app effectively pauses until the user confirms or cancels.
class UpdateInstalling extends UpdateState {
  /// Creates an [UpdateInstalling] for the given [info].
  const UpdateInstalling(this.info);

  /// The release being installed.
  final ReleaseInfo info;

  @override
  List<Object?> get props => [info];
}

/// Something went wrong somewhere in the chain.
///
/// Inspect [failure] for details. If [wasMandatory] is true the host app
/// should remain blocked and only allow retry / exit.
class UpdateFailed extends UpdateState {
  /// Creates an [UpdateFailed] from a [failure].
  const UpdateFailed({
    required this.failure,
    required this.wasMandatory,
    this.info,
  });

  /// The underlying failure.
  final UpdateFailure failure;

  /// Whether the failed update was mandatory; controls whether the host
  /// app stays blocked.
  final bool wasMandatory;

  /// The release that was being processed, if known.
  final ReleaseInfo? info;

  @override
  List<Object?> get props => [failure, wasMandatory, info];
}
