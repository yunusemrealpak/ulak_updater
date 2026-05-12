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
    ),
  );

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ulak Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
      ),
      home: const UpdateGate(child: HomeScreen()),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saha Uygulaması')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 56, color: Colors.greenAccent),
              SizedBox(height: 14),
              Text(
                'Demo host arayüzü',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Uygulama her açılışta arka planda güncelleme kontrolü yapar.\n'
                'Yeni sürüm bulunduğunda akış otomatik başlar.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
