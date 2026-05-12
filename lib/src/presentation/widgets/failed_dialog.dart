import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/update_state.dart';
import '../../domain/failures/update_failure.dart';
import '../cubit/update_cubit.dart';
import '../ulak_updater.dart';

class FailedDialog extends StatelessWidget {
  const FailedDialog({super.key, required this.state});
  final UpdateFailed state;

  @override
  Widget build(BuildContext context) {
    final copy = UlakUpdater.instance.config.copy;
    final theme = Theme.of(context);
    final isPermission = state.failure is InstallPermissionFailure;
    final title = isPermission ? copy.permissionNeededTitle : copy.errorTitle;
    final body = isPermission ? copy.permissionNeededBody : state.failure.message;

    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text(body, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (state.wasMandatory)
                          TextButton(
                            onPressed: () => SystemNavigator.pop(),
                            child: Text(copy.mandatoryExit),
                          ),
                        if (!state.wasMandatory)
                          TextButton(
                            onPressed: () =>
                                context.read<UpdateCubit>().declineOptional(),
                            child: Text(copy.optionalLater),
                          ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () {
                            final info = state.info;
                            if (info == null) {
                              context.read<UpdateCubit>().check();
                              return;
                            }
                            context.read<UpdateCubit>().retry(
                                  info,
                                  wasMandatory: state.wasMandatory,
                                );
                          },
                          child: Text(copy.errorRetry),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
