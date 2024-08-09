import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'camera_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';

class VoiceRecognition extends StatefulWidget {
  const VoiceRecognition({super.key});

  @override
  State<VoiceRecognition> createState() => _VoiceRecognitionState();
}

class _VoiceRecognitionState extends State<VoiceRecognition> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  String _text = "Initializing...";
  late List<CameraDescription> _cameras;
  final String _apiKey = ''; // Replace with your API key

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _requestPermission();
    _initializeCameras();
    _speak(
        "The app is ready to receive commands. Please say 'take a picture' to open the camera.");
    _listenContinuously();
  }

  void _requestPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
  }

  void _initializeCameras() async {
    _cameras = await availableCameras();
  }

  void _speak(String text) async {
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
        logger.e('onError:', error: '$val');
        _listenContinuously();
      },
    );
    if (available) {
      _speech.listen(
        onResult: (val) => setState(() {
          _text = val.recognizedWords;
          if (val.hasConfidenceRating && val.confidence > 0) {
            loggerNoStack.i('Recognized: $_text');
            if (_text.toLowerCase().contains('take a picture')) {
              _openCamera();
            }
          }
        }),
      );
    }
  }

  void _openCamera() {
    if (_cameras.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            camera: _cameras.first,
            onPictureTaken: _analyzePicture,
          ),
        ),
      );
    } else {
      logger.w('No cameras available');
    }
  }

  Future<void> _analyzePicture(String imagePath) async {
    _speak("Analizando a imagem.");
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);

      final imageBytes = File(imagePath).readAsBytesSync();

      final prompt = TextPart(
          "Identifique o medicamento da imagem e dê um resumo prático com a menor quantidade de linhas possível sendo bem objetivo e simples como se estivesse falando com uma vovó bem velhinha, incluindo informações da bula de como usar e para que serve, sem adicionar quaisquer outros pontos que não sejam fatais caso não sejam explicados, caso a vovó que será medicada não saiba, deixe o aviso de que só pode ser usado sob recomendações médicas.");
      final imageParts = [
        DataPart('image/jpeg', imageBytes),
      ];
      final response = await model.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);
      logger.i(response.text);
      _speak(response.text ?? 'Error: No response text');
    } catch (e) {
      loggerNoStack.e('VOICE Error analyzing picture:', error: '$e');
      _speak("Error analyzing the picture.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amynk'),
      ),
      body: Center(
        child: Text(
          _text,
          style: const TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
