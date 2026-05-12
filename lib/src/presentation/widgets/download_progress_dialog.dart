import 'package:flutter/material.dart';

import '../../domain/entities/update_state.dart';
import '../ulak_updater.dart';

class DownloadProgressDialog extends StatelessWidget {
  const DownloadProgressDialog({super.key, required this.state});
  final UpdateDownloading state;

  @override
  Widget build(BuildContext context) {
    final copy = UlakUpdater.instance.config.copy;
    final theme = Theme.of(context);
    final pct = (state.fraction * 100).clamp(0.0, 100.0);
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
                  color: theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${copy.downloadingTitle}  v${state.info.versionName}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 14),
                    LinearProgressIndicator(value: state.fraction.clamp(0.0, 1.0)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${pct.toStringAsFixed(0)}%'),
                        Text(_formatBytes(state.receivedBytes, state.totalBytes)),
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

  String _formatBytes(int received, int total) {
    return '${_human(received)} / ${_human(total)}';
  }

  String _human(int n) {
    if (n <= 0) return '—';
    const units = ['B', 'KB', 'MB', 'GB'];
    var v = n.toDouble();
    var i = 0;
    while (v >= 1024 && i < units.length - 1) {
      v /= 1024;
      i++;
    }
    return '${v.toStringAsFixed(v < 10 && i > 0 ? 1 : 0)} ${units[i]}';
  }
}
