import 'package:equatable/equatable.dart';

import 'release_info.dart';
import '../failures/update_failure.dart';

/// State machine values for the update flow. Sealed so the UI can exhaustively
/// switch on every possibility.
sealed class UpdateState extends Equatable {
  const UpdateState();

  @override
  List<Object?> get props => const [];
}

class UpdateInitial extends UpdateState {
  const UpdateInitial();
}

class UpdateChecking extends UpdateState {
  const UpdateChecking();
}

/// Server is unreachable; per "yumuşak" policy, host app may proceed but
/// a passive notice is shown.
class UpdateCheckOffline extends UpdateState {
  const UpdateCheckOffline();
}

/// Device is up to date; host app may render normally.
class UpdateNotRequired extends UpdateState {
  const UpdateNotRequired();
}

/// A newer version exists, but is not mandatory; user may defer.
class UpdateOptional extends UpdateState {
  const UpdateOptional(this.info);
  final ReleaseInfo info;

  @override
  List<Object?> get props => [info];
}

/// A newer version exists and is mandatory; user must update or exit.
class UpdateMandatory extends UpdateState {
  const UpdateMandatory(this.info);
  final ReleaseInfo info;

  @override
  List<Object?> get props => [info];
}

class UpdateDownloading extends UpdateState {
  const UpdateDownloading({
    required this.info,
    required this.receivedBytes,
    required this.totalBytes,
  });
  final ReleaseInfo info;
  final int receivedBytes;
  final int totalBytes;

  double get fraction => totalBytes <= 0 ? 0 : receivedBytes / totalBytes;

  @override
  List<Object?> get props => [info, receivedBytes, totalBytes];
}

class UpdateVerifying extends UpdateState {
  const UpdateVerifying(this.info);
  final ReleaseInfo info;

  @override
  List<Object?> get props => [info];
}

class UpdateInstalling extends UpdateState {
  const UpdateInstalling(this.info);
  final ReleaseInfo info;

  @override
  List<Object?> get props => [info];
}

class UpdateFailed extends UpdateState {
  const UpdateFailed({
    required this.failure,
    required this.wasMandatory,
    this.info,
  });
  final UpdateFailure failure;
  final bool wasMandatory;
  final ReleaseInfo? info;

  @override
  List<Object?> get props => [failure, wasMandatory, info];
}
