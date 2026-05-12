import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/release_info.dart';
import '../cubit/update_cubit.dart';
import '../ulak_updater.dart';

class UpdateOptionalDialog extends StatelessWidget {
  const UpdateOptionalDialog({super.key, required this.info});
  final ReleaseInfo info;

  @override
  Widget build(BuildContext context) {
    final copy = UlakUpdater.instance.config.copy;
    return _DimmedDialog(
      child: _DialogCard(
        title: copy.optionalTitle,
        version: info.versionName,
        notes: info.releaseNotes,
        notesTitle: copy.releaseNotesTitle,
        primaryLabel: copy.optionalCta,
        onPrimary: () =>
            context.read<UpdateCubit>().startUpdate(info, wasMandatory: false),
        secondaryLabel: copy.optionalLater,
        onSecondary: () => context.read<UpdateCubit>().declineOptional(),
      ),
    );
  }
}

class _DimmedDialog extends StatelessWidget {
  const _DimmedDialog({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogCard extends StatelessWidget {
  const _DialogCard({
    required this.title,
    required this.version,
    required this.notes,
    required this.notesTitle,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final String version;
  final String notes;
  final String notesTitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      decoration: BoxDecoration(
        color: theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'v$version',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(notesTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: SingleChildScrollView(
                child: Text(notes, style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (secondaryLabel != null && onSecondary != null)
                TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
              const SizedBox(width: 8),
              FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
            ],
          ),
        ],
      ),
    );
  }
}
