import 'package:fpdart/fpdart.dart';

import '../failures/update_failure.dart';
import '../repositories/update_repository.dart';

class VerifyApk {
  VerifyApk(this.repo);
  final UpdateRepository repo;

  Future<Either<UpdateFailure, Unit>> call({
    required String filePath,
    required String expectedSha256,
  }) =>
      repo.verifyApk(filePath: filePath, expectedSha256: expectedSha256);
}
