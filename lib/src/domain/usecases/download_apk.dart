import 'package:fpdart/fpdart.dart';

import '../entities/release_info.dart';
import '../failures/update_failure.dart';
import '../repositories/update_repository.dart';

class DownloadApk {
  DownloadApk(this.repo);
  final UpdateRepository repo;

  Future<Either<UpdateFailure, String>> call({
    required ReleaseInfo info,
    required void Function(int received, int total) onProgress,
  }) =>
      repo.downloadApk(info: info, onProgress: onProgress);
}
