import 'dart:async';

import 'package:logger/logger.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecognition {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  late Function(String) _onRecognized;

  VoiceRecognition({required Function(String) onRecognized}) {
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _onRecognized = onRecognized;
  }

  Future<void> initialize() async {
    await _requestPermission();
    //await _speak("");
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
            _onRecognized(val.recognizedWords);
          }
        },
      );
    }
  }

  Future<String?> listenForInput() async {
    bool available = await _speech.initialize();
    if (available) {
      final completer = Completer<String?>();
      _speech.listen(onResult: (val) {
        Logger().i('Speech recognition result: $val');
        if (val.hasConfidenceRating && val.confidence > 0) {
          Logger().i('Confidence rating: ${val.confidence}');
          _speech.stop();
          completer.complete(val.recognizedWords);
        } else {
          Logger().w('No confidence rating or confidence too low');
        }
      }).catchError((error) {
        Logger().e('Speech recognition error: $error');
      });
      return completer.future;
    }
    return null;
  }

  void setOnRecognizedCallback(Function(String) callback) {
    _onRecognized = callback;
  }

  FlutterTts get flutterTts => _flutterTts;
}
