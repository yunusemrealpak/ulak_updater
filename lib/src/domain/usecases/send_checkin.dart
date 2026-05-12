import '../repositories/update_repository.dart';

class SendCheckin {
  SendCheckin(this.repo);
  final UpdateRepository repo;

  Future<void> call({
    required int currentVersionCode,
    required String currentVersionName,
  }) =>
      repo.sendCheckin(
        currentVersionCode: currentVersionCode,
        currentVersionName: currentVersionName,
      );
}
