import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';
import 'google_gemini_bloc.dart';

class ImageAnalyzing {
  final Logger logger;
  final FlutterTts flutterTts;
  final GoogleGeminiBloc googleGeminiBloc;

  ImageAnalyzing(
      {required this.logger,
      required this.flutterTts,
      required this.googleGeminiBloc});

  Future<void> analyzePicture(String imagePath) async {
    await _speak("Analizando a imagem.");
    try {
      final imageBytes = File(imagePath).readAsBytesSync();
      final responseText = await googleGeminiBloc.analyzeImage(imageBytes);

      logger.i(responseText);
      String explicationMedicine =
          responseText?.replaceAll('*', '') ?? 'Erro, sem resposta';
      await _speak(explicationMedicine);

      // Extract the medicine name from the response text
      String? nameMedicine = _extractMedicineName(explicationMedicine);

      if (nameMedicine == null) {
        // If the medicine name is not found, make a subsequent call to refine the information
        final refineResponseText =
            await googleGeminiBloc.refineMedicineName(explicationMedicine);
        nameMedicine = refineResponseText?.replaceAll('*', '') ?? 'Error';
      }

      logger.i('Medicine Name: $nameMedicine');
    } catch (e) {
      logger.e('VOICE Error analyzing picture:', error: '$e');
      _speak("Erro ao analisar a imagem.");
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  String? _extractMedicineName(String text) {
    // Use a regular expression to extract the medicine name
    final RegExp nameRegExp = RegExp(r'name\s*:\s*(\w+)', caseSensitive: false);
    final match = nameRegExp.firstMatch(text);
    return match?.group(1);
  }
}
