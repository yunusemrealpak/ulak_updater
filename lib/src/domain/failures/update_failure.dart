import 'package:equatable/equatable.dart';

/// Domain-level failure types raised by the update flow.
///
/// Sealed so callers can exhaustively switch on each subtype. All failures
/// carry a human-readable [message] suitable for diagnostics; the bundled
/// UI does not render it directly.
sealed class UpdateFailure extends Equatable {
  /// Const constructor for subclasses.
  const UpdateFailure(this.message);

  /// Human-readable diagnostic message. Not localized.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Network unreachable, timeout, DNS failure, or TLS error.
class NetworkFailure extends UpdateFailure {
  /// Creates a [NetworkFailure].
  const NetworkFailure(super.message);
}

/// Server responded with a non-2xx status code.
class ServerFailure extends UpdateFailure {
  /// Creates a [ServerFailure] with the HTTP [statusCode].
  const ServerFailure(super.message, this.statusCode);

  /// The HTTP status code returned by the server.
  final int statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Local I/O error (e.g. no space, cache directory unavailable, permission).
class StorageFailure extends UpdateFailure {
  /// Creates a [StorageFailure].
  const StorageFailure(super.message);
}

/// Downloaded APK's SHA-256 did not match [ReleaseInfo.sha256]. The file
/// has been deleted; nothing is installed.
class IntegrityFailure extends UpdateFailure {
  /// Creates an [IntegrityFailure].
  const IntegrityFailure(super.message);
}

/// Android refused to install because `REQUEST_INSTALL_PACKAGES` is not
/// granted. The bundled UI then deep-links the user into Settings.
class InstallPermissionFailure extends UpdateFailure {
  /// Creates an [InstallPermissionFailure].
  const InstallPermissionFailure(super.message);
}

/// The install intent itself failed (e.g. signature mismatch with the
/// currently installed app, malformed APK).
class InstallFailure extends UpdateFailure {
  /// Creates an [InstallFailure].
  const InstallFailure(super.message);
}

/// Catch-all for anything that does not map to a more specific failure.
class UnknownFailure extends UpdateFailure {
  /// Creates an [UnknownFailure].
  const UnknownFailure(super.message);
}
