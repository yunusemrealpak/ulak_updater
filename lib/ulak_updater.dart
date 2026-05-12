/// Self-hosted, Android-only in-app updater for Flutter.
///
/// `ulak_updater` lets internal / field-deployed Flutter apps that are not
/// shipped through Google Play check a self-hosted server for new APK
/// releases, download them with progress, verify integrity via SHA-256, and
/// trigger Android's native install dialog with a single tap.
///
/// ## Quick start
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:ulak_updater/ulak_updater.dart';
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await UlakUpdater.init(
///     config: const UlakUpdaterConfig(baseUrl: 'https://updates.example.com'),
///   );
///   runApp(const MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///   @override
///   Widget build(BuildContext context) {
///     return const MaterialApp(home: UpdateGate(child: HomeScreen()));
///   }
/// }
/// ```
///
/// ## Public API
///
/// The three types most apps need:
///
/// - [UlakUpdater] — singleton; call [UlakUpdater.init] once before `runApp`.
/// - [UlakUpdaterConfig] — base URL, channel, timeouts, copy.
/// - [UpdateGate] — wraps your home widget and drives the update flow.
///
/// Domain types ([ReleaseInfo], [UpdateState], [UpdateFailure]) are exported
/// so advanced apps can build a custom UI on top of `UlakUpdater.instance.cubit`.
library;

export 'src/presentation/ulak_updater.dart';
export 'src/presentation/ulak_updater_config.dart';
export 'src/presentation/widgets/update_gate.dart';

export 'src/domain/entities/release_info.dart';
export 'src/domain/entities/update_state.dart';
export 'src/domain/failures/update_failure.dart';
