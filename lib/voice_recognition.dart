import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecognition {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  final Function(String) onRecognized;

  VoiceRecognition({required this.onRecognized}) {
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
  }

  Future<void> initialize() async {
    await _requestPermission();
    await _speak(
        "Estou pronto para te ajudar com os seus remédios. É só falar Ver Remédio para abrir a câmera.");
    _listenContinuously();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _listenContinuously() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == "done" || val == "notListening") {
          _listenContinuously();
        }
      },
      onError: (val) {
        _listenContinuously();
      },
      debugLogging: false,
    );

    if (available) {
      _speech.listen(
        onResult: (val) {
          if (val.hasConfidenceRating && val.confidence > 0) {
            onRecognized(val.recognizedWords);
          }
        },
      );
    }
  }

  FlutterTts get flutterTts => _flutterTts;
}
