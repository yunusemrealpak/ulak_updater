import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/release_info.dart';
import '../../domain/entities/update_state.dart';
import '../../domain/usecases/check_for_update.dart';
import '../../domain/usecases/download_apk.dart';
import '../../domain/usecases/install_apk.dart';
import '../../domain/usecases/send_checkin.dart';
import '../../domain/usecases/verify_apk.dart';

class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit({
    required this.checkForUpdate,
    required this.downloadApk,
    required this.verifyApk,
    required this.installApk,
    required this.sendCheckin,
    required this.currentVersionCode,
    required this.currentVersionName,
  }) : super(const UpdateInitial());

  final CheckForUpdate checkForUpdate;
  final DownloadApk downloadApk;
  final VerifyApk verifyApk;
  final InstallApk installApk;
  final SendCheckin sendCheckin;

  final int currentVersionCode;
  final String currentVersionName;

  Future<void> check() async {
    emit(const UpdateChecking());
    final state = await checkForUpdate(currentVersionCode: currentVersionCode);
    emit(state);

    // fire-and-forget checkin (never blocks UI)
    unawaited(sendCheckin(
      currentVersionCode: currentVersionCode,
      currentVersionName: currentVersionName,
    ),);
  }

  /// Triggered when the user taps "Yükle" on the optional or mandatory dialog.
  Future<void> startUpdate(ReleaseInfo info, {required bool wasMandatory}) async {
    emit(UpdateDownloading(
      info: info,
      receivedBytes: 0,
      totalBytes: info.fileSize,
    ),);

    final downloadResult = await downloadApk(
      info: info,
      onProgress: (received, total) {
        if (!isClosed && state is UpdateDownloading) {
          emit(UpdateDownloading(
            info: info,
            receivedBytes: received,
            totalBytes: total > 0 ? total : info.fileSize,
          ),);
        }
      },
    );

    final filePath = downloadResult.fold<String?>((failure) {
      emit(UpdateFailed(failure: failure, wasMandatory: wasMandatory, info: info));
      return null;
    }, (path) => path,);
    if (filePath == null) return;

    emit(UpdateVerifying(info));
    final verifyResult = await verifyApk(
      filePath: filePath,
      expectedSha256: info.sha256,
    );
    final verified = verifyResult.fold<bool>((failure) {
      emit(UpdateFailed(failure: failure, wasMandatory: wasMandatory, info: info));
      return false;
    }, (_) => true,);
    if (!verified) return;

    emit(UpdateInstalling(info));
    final installResult = await installApk(filePath);
    installResult.fold((failure) {
      emit(UpdateFailed(failure: failure, wasMandatory: wasMandatory, info: info));
    }, (_) {
      // The Android system dialog is now visible. If the user confirms,
      // our process is killed. If they cancel, we stay in UpdateInstalling
      // — the UI shows a Retry button to call this method again.
    });
  }

  /// User tapped "Sonra" on an optional update.
  void declineOptional() {
    emit(const UpdateNotRequired());
  }

  /// Reset to checking after a failed update.
  void retry(ReleaseInfo info, {required bool wasMandatory}) {
    startUpdate(info, wasMandatory: wasMandatory);
  }
}
