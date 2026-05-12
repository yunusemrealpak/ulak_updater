import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/update_state.dart';
import '../cubit/update_cubit.dart';
import '../ulak_updater.dart';
import 'download_progress_dialog.dart';
import 'failed_dialog.dart';
import 'text_overlay_dialog.dart';
import 'update_optional_dialog.dart';
import 'update_required_screen.dart';

/// Wraps the host's home widget. While update flow is active, dialogs are
/// painted as a Stack overlay; mandatory updates fully replace the child.
class UpdateGate extends StatefulWidget {
  const UpdateGate({super.key, required this.child});
  final Widget child;

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  UpdateCubit get _cubit => UlakUpdater.instance.cubit;

  @override
  void initState() {
    super.initState();
    if (UlakUpdater.instance.config.checkOnStartup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cubit.check();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = UlakUpdater.instance.config.copy;
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<UpdateCubit, UpdateState>(
        builder: (ctx, state) {
          if (state is UpdateMandatory) {
            return UpdateRequiredScreen(info: state.info);
          }
          return Stack(
            children: [
              Positioned.fill(child: widget.child),
              if (state is UpdateOptional)
                UpdateOptionalDialog(info: state.info),
              if (state is UpdateDownloading)
                DownloadProgressDialog(state: state),
              if (state is UpdateVerifying)
                TextOverlayDialog(label: copy.verifyingTitle),
              if (state is UpdateInstalling)
                TextOverlayDialog(label: copy.installingTitle),
              if (state is UpdateFailed)
                FailedDialog(state: state),
              if (state is UpdateCheckOffline) const _OfflineToast(),
            ],
          );
        },
      ),
    );
  }
}

class _OfflineToast extends StatefulWidget {
  const _OfflineToast();

  @override
  State<_OfflineToast> createState() => _OfflineToastState();
}

class _OfflineToastState extends State<_OfflineToast> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final copy = UlakUpdater.instance.config.copy;
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24 + MediaQuery.of(context).padding.bottom,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_off, color: Colors.white70, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    copy.offlineNotice,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
