import 'package:flutter/material.dart';
import 'main/main_list_page.dart'; // MainPage 정의된 파일
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PersonalityTest',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA7C7E7),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        cardColor: const Color(0xFFE6F0FA),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF333333)),
        ),
      ),
      home: const MainPage(), //수정된 부분
    );
  }
}
