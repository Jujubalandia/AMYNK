import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';
import 'package:camera/camera.dart';
import 'google_gemini_bloc.dart';
import 'camera_screen.dart';

class ImageAnalyzing {
  final Logger logger;
  final FlutterTts flutterTts;
  final GoogleGeminiBloc googleGeminiBloc;
  late List<CameraDescription> _cameras;

  ImageAnalyzing(
      {required this.logger,
      required this.flutterTts,
      required this.googleGeminiBloc});

  void setCameras(List<CameraDescription> cameras) {
    _cameras = cameras;
  }

  void openCamera(BuildContext context) {
    if (_cameras.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            camera: _cameras.first,
            onPictureTaken: analyzePicture,
          ),
        ),
      );
    } else {
      logger.w('No cameras available');
    }
  }

  Future<void> analyzePicture(String imagePath) async {
    await _speak("Analizando a imagem.");
    try {
      final imageBytes = File(imagePath).readAsBytesSync();
      final responseText = await googleGeminiBloc.analyzeImage(imageBytes);

      logger.i(responseText);
      String explicationMedicine =
          responseText?.replaceAll('*', '') ?? 'Erro, sem resposta';
      await _speak(explicationMedicine);
    } catch (e) {
      logger.e('VOICE Error analyzing picture:', error: '$e');
      _speak("Erro ao analisar a imagem.");
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }
}
