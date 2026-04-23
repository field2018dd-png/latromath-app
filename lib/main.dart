import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const LatromathApp());
}

class LatromathApp extends StatelessWidget {
  const LatromathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Latromath',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8390E),
          brightness: Brightness.light,
        ),
        fontFamily: 'Sarabun',
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}