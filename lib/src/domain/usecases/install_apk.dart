import 'package:fpdart/fpdart.dart';

import '../failures/update_failure.dart';
import '../repositories/update_repository.dart';

class InstallApk {
  InstallApk(this.repo);
  final UpdateRepository repo;

  Future<Either<UpdateFailure, Unit>> call(String filePath) =>
      repo.installApk(filePath);
}
