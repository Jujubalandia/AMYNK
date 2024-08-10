import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'camera_screen.dart';
import 'voice_recognition.dart';
import 'image_analyzing.dart';
import 'google_gemini_bloc.dart';

class UserFlow extends StatefulWidget {
  final String title;

  const UserFlow({super.key, required this.title});

  @override
  State<UserFlow> createState() => _UserFlowState();
}

class _UserFlowState extends State<UserFlow> {
  late VoiceRecognition _voiceRecognition;
  late ImageAnalyzing _imageAnalyzing;
  late List<CameraDescription> _cameras;
  final String _apiKey = '';

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    final googleGeminiBloc = GoogleGeminiBloc(apiKey: '');
    _voiceRecognition = VoiceRecognition(onRecognized: _onRecognized);
    _imageAnalyzing = ImageAnalyzing(
        logger: logger,
        flutterTts: _voiceRecognition.flutterTts,
        googleGeminiBloc: googleGeminiBloc);

    _initializeCameras();
    _voiceRecognition.initialize();
  }

  void _initializeCameras() async {
    _cameras = await availableCameras();
  }

  void _onRecognized(String text) {
    setState(() {
      if (text.toLowerCase().contains('remédio')) {
        _openCamera();
      }
    });
  }

  void _openCamera() {
    if (_cameras.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            camera: _cameras.first,
            onPictureTaken: _imageAnalyzing.analyzePicture,
          ),
        ),
      );
    } else {
      logger.w('No cameras available');
    }
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
