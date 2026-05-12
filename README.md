# ulak_updater

Self-hosted, Android-only in-app updater for Flutter. Designed for field-deployed
internal apps that aren't shipped through Play Store.

- App-startup version check against `https://your-host/v1/version`
- APK download with progress + SHA-256 verification
- One-tap install via `REQUEST_INSTALL_PACKAGES` (no Device Owner required)
- `mandatory: true` releases hard-block the host app until the user updates
- Soft offline policy: an unreachable server shows a passive notice and lets
  the host app proceed
- Anonymous device check-in (UUID + versionCode) for telemetry
- Clean Architecture (data / domain / presentation), Either<Failure,T>,
  flutter_bloc Cubit

## Install

In your app's `pubspec.yaml`:

```yaml
dependencies:
  ulak_updater:
    path: ../path/to/ulak_updater   # or git ref
```

## Wire it into the app

```dart
import 'package:flutter/material.dart';
import 'package:ulak_updater/ulak_updater.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UlakUpdater.init(
    config: const UlakUpdaterConfig(
      baseUrl: String.fromEnvironment(
        'ULAK_BASE_URL',
        defaultValue: 'https://ulak.tepvox.com',
      ),
      project: String.fromEnvironment(
        'ULAK_PROJECT',
        defaultValue: 'saha',
      ),
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UpdateGate(child: HomeScreen()),
    );
  }
}
```

Build with:

```bash
flutter build apk --release \
  --dart-define=ULAK_BASE_URL=https://ulak.tepvox.com \
  --dart-define=ULAK_PROJECT=saha
```

## Required AndroidManifest entries

Add to your **host app** `android/app/src/main/AndroidManifest.xml`
(the package itself ships nothing here — see `AndroidManifest.xml`):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />

    <application ...>
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.ulakprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/ulak_file_paths" />
        </provider>

        <activity ...> ... </activity>
    </application>
</manifest>
```

The `ulak_file_paths` xml resource is shipped by this package; no extra file
is needed in the host.

## Versioning

Use SemVer + buildNumber in your host's `pubspec.yaml`:

```yaml
version: 1.4.3+87   # versionName=1.4.3, versionCode=87
```

The server compares **versionCode** strictly; bump it on every release.

## Update flow

```
app start
  └─ /v1/version → 200
       ├─ versionCode <= installed → host app
       └─ newer
           ├─ mandatory=false → optional dialog (Yükle / Sonra)
           └─ mandatory=true  → fullscreen gate (Yükle / Çıkış)
                  ↓
           download (progress) → SHA-256 verify → PackageInstaller intent
                  ↓
           Android shows native "Install?" dialog → user taps Install → restart
```

If `/v1/version` fails (offline / 5xx): a passive toast shows and the host
app continues with the currently installed version.

## Customizing copy

`UlakUpdaterCopy` exposes every Turkish string. Override individually:

```dart
UlakUpdaterConfig(
  baseUrl: '...',
  copy: UlakUpdaterCopy(
    optionalCta: 'Şimdi yükle',
    optionalLater: 'Daha sonra',
  ),
)
```

## Architecture

```
lib/
├── ulak_updater.dart                       # public barrel
└── src/
    ├── data/
    │   ├── datasources/                    # Dio + Hive
    │   ├── models/
    │   ├── repositories/                   # Either<Failure, T>
    │   └── utils/sha256_verifier.dart
    ├── domain/
    │   ├── entities/                       # ReleaseInfo, UpdateState (sealed)
    │   ├── failures/                       # UpdateFailure (sealed)
    │   ├── repositories/
    │   └── usecases/                       # CheckForUpdate, Download, ...
    ├── platform/android_installer.dart     # MethodChannel
    └── presentation/
        ├── cubit/                          # UpdateCubit (state machine)
        ├── ulak_updater.dart               # singleton init
        ├── ulak_updater_config.dart
        └── widgets/                        # UpdateGate + dialogs
```

## License

MIT — see [LICENSE](LICENSE).
