import 'package:flutter/material.dart';
import 'voice_recognition.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'All Medicine You Need Known',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VoiceRecognition(),
    );
  }
}
