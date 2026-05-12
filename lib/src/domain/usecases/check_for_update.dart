import '../entities/release_info.dart';
import '../entities/update_state.dart';
import '../failures/update_failure.dart';
import '../repositories/update_repository.dart';

/// Compares the running app's versionCode with the latest release advertised
/// by the server, and returns the corresponding UpdateState.
class CheckForUpdate {
  CheckForUpdate(this.repo);
  final UpdateRepository repo;

  /// [currentVersionCode] should come from PackageInfo at startup.
  Future<UpdateState> call({required int currentVersionCode}) async {
    final result = await repo.getCurrentRelease();
    return result.fold(
      (failure) => _stateFromFailure(failure),
      (info) => _compare(currentVersionCode, info),
    );
  }

  UpdateState _compare(int currentCode, ReleaseInfo info) {
    if (currentCode >= info.versionCode) {
      return const UpdateNotRequired();
    }
    if (info.mandatory) {
      return UpdateMandatory(info);
    }
    return UpdateOptional(info);
  }

  UpdateState _stateFromFailure(UpdateFailure failure) {
    // Soft offline policy: if we can't reach the server, surface
    // UpdateCheckOffline rather than UpdateFailed. The host app proceeds.
    if (failure is NetworkFailure) {
      return const UpdateCheckOffline();
    }
    if (failure is ServerFailure && failure.statusCode == 404) {
      // No published release for channel -> treat as up to date.
      return const UpdateNotRequired();
    }
    return UpdateFailed(failure: failure, wasMandatory: false);
  }
}
