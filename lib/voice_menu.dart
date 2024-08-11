import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';
import 'voice_recognition.dart';
import 'image_analyzing.dart';
import 'schedule_medicine.dart';

class VoiceMenu {
  final Logger logger;
  final FlutterTts flutterTts;
  final VoiceRecognition voiceRecognition;
  final ImageAnalyzing imageAnalyzing;
  final ScheduleMedicine scheduleMedicine;
  final BuildContext context;

  VoiceMenu({
    required this.logger,
    required this.flutterTts,
    required this.voiceRecognition,
    required this.imageAnalyzing,
    required this.scheduleMedicine,
    required this.context,
  });

  void initialize() {
    voiceRecognition.setOnRecognizedCallback(onRecognized);
    _speakMenuOptions();
  }

  void _speakMenuOptions() async {
    await flutterTts.speak("""
           As opções disponíveis são: Ver remédio agendar e voltar ao menu.
           Estou pronto para te ajudar com os seus remédios. É só falar Ver Remédio para abrir a câmera.
           Ou falar Agendar para agendar para tomar um remédio.
           Para voltar ao menu inicial e repetir as opções só falar Voltar
        """);
  }

  void onRecognized(String text) {
    if (text.toLowerCase().contains('ver remédio')) {
      _openCamera();
    } else if (text.toLowerCase().contains('agendar')) {
      _scheduleMedicine();
    } else if (text.toLowerCase().contains('voltar')) {
      _speakMenuOptions();
    }
  }

  void _openCamera() {
    imageAnalyzing.openCamera(context);
  }

  void _scheduleMedicine() async {
    await flutterTts.speak("Por favor, diga o nome do remédio.");
    String? medicineName = await voiceRecognition.listenForInput();
    await flutterTts.speak("Por favor, diga a hora para tomar o remédio.");
    String? time = await voiceRecognition.listenForInput();

    if (medicineName != null && time != null) {
      await flutterTts.speak("Você disse: Remédio $medicineName às $time.");
      logger.i('Agendar: Remédio $medicineName às $time');
      await flutterTts.speak("Você quer voltar ao menu? Diga sim ou não.");
      String? response = await voiceRecognition.listenForInput();

      if (response != null && response.toLowerCase().contains('sim')) {
        _speakMenuOptions();
      }
    }
  }
}
