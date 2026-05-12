import 'package:equatable/equatable.dart';

sealed class UpdateFailure extends Equatable {
  const UpdateFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends UpdateFailure {
  const NetworkFailure(super.message);
}

class ServerFailure extends UpdateFailure {
  const ServerFailure(super.message, this.statusCode);
  final int statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class StorageFailure extends UpdateFailure {
  const StorageFailure(super.message);
}

class IntegrityFailure extends UpdateFailure {
  const IntegrityFailure(super.message);
}

class InstallPermissionFailure extends UpdateFailure {
  const InstallPermissionFailure(super.message);
}

class InstallFailure extends UpdateFailure {
  const InstallFailure(super.message);
}

class UnknownFailure extends UpdateFailure {
  const UnknownFailure(super.message);
}
