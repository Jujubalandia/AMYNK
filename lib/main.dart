import 'package:flutter/material.dart';
import 'voice_recognition.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Assistance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VoiceRecognition(),
    );
  }
}
