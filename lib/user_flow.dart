import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'voice_recognition.dart';
import 'image_analyzing.dart';
import 'google_gemini_bloc.dart';
import 'voice_menu.dart';
import 'schedule_medicine.dart';

class UserFlow extends StatefulWidget {
  final String title;

  const UserFlow({super.key, required this.title});

  @override
  State<UserFlow> createState() => _UserFlowState();
}

class _UserFlowState extends State<UserFlow> {
  late VoiceRecognition _voiceRecognition;
  late ImageAnalyzing _imageAnalyzing;
  late ScheduleMedicine _scheduleMedicine;
  late VoiceMenu _voiceMenu;
  late List<CameraDescription> _cameras;
  final String _apiKey = 'AIzaSyCQR7C0s-JZ22MNHvV3yTKucHO4dWTGMDs';

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    final googleGeminiBloc = GoogleGeminiBloc(apiKey: _apiKey);
    _voiceRecognition = VoiceRecognition(onRecognized: _onRecognized);
    _imageAnalyzing = ImageAnalyzing(
        logger: logger,
        flutterTts: _voiceRecognition.flutterTts,
        googleGeminiBloc: googleGeminiBloc);
    _scheduleMedicine = ScheduleMedicine(logger: logger);
    _voiceMenu = VoiceMenu(
      logger: logger,
      flutterTts: _voiceRecognition.flutterTts,
      voiceRecognition: _voiceRecognition,
      imageAnalyzing: _imageAnalyzing,
      scheduleMedicine: _scheduleMedicine,
      context: context, // Pass the context here
    );

    _initializeCameras();
    _voiceRecognition.initialize();
    _voiceMenu.initialize();
  }

  void _initializeCameras() async {
    _cameras = await availableCameras();
    _imageAnalyzing
        .setCameras(_cameras); // Set the cameras in the ImageAnalyzing class
  }

  void _onRecognized(String text) {
    setState(() {
      _voiceMenu.onRecognized(text); // Use the public method here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amynk'),
      ),
      body: const Center(
        child: Text(
          '',
          style: TextStyle(fontSize: 24.0),
          //TO-DO: implement the logic to Speak on Tap on screen
        ),
      ),
    );
  }
}
