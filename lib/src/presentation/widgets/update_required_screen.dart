import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/release_info.dart';
import '../cubit/update_cubit.dart';
import '../ulak_updater.dart';

/// Fullscreen replacement shown while a mandatory update is pending.
/// The host UI is fully gated until the install dialog completes.
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key, required this.info});
  final ReleaseInfo info;

  @override
  Widget build(BuildContext context) {
    final copy = UlakUpdater.instance.config.copy;
    final theme = Theme.of(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Icon(Icons.system_update, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(copy.mandatoryTitle, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'v${info.versionName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Text(copy.mandatoryBody, style: theme.textTheme.bodyLarge),
                if (info.releaseNotes.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(copy.releaseNotesTitle, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(info.releaseNotes, style: theme.textTheme.bodyMedium),
                    ),
                  ),
                ] else
                  const Spacer(),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.read<UpdateCubit>().startUpdate(info, wasMandatory: true),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(copy.mandatoryCta),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: Text(copy.mandatoryExit),
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
