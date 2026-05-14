import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env yükle
  await dotenv.load(fileName: '.env');

  // Firebase başlat
  await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: CaoriaApp(),
    ),
  );
}

class CaoriaApp extends StatelessWidget {
  const CaoriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caloria',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Caloria'),
        ),
      ),
    );
  }
}