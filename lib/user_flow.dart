import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'camera_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logger/logger.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class UserFlow extends StatefulWidget {
  final String title;

  const UserFlow({super.key, required this.title});

  @override
  State<UserFlow> createState() => _UserFlowState();
}

class _UserFlowState extends State<UserFlow> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  String _text = "Iniciando ...";
  late List<CameraDescription> _cameras;
  final String _apiKey = '';

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _requestPermission();
    _initializeCameras();
    _speak("""
          Estou pronto para te ajudar com os seus remédios 
          É só falar Ver Remédio para abrir a câmera.
       """);
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
        //logger.e('onError: $val');
        _listenContinuously();
      },
      debugLogging: false,
    );

    if (available) {
      _speech.listen(
        onResult: (val) => setState(() {
          _text = val.recognizedWords;
          if (val.hasConfidenceRating && val.confidence > 0) {
            logger.i('Recognized: $_text');
            if (_text.toLowerCase().contains('remédio')) {
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

      final prompt =
          TextPart("""Identifique o medicamento da imagem e dê um resumo prático
             com a menor quantidade de linhas possível, sendo bem objetivo e 
             simples como se estivesse falando com uma pessoa bem idosa, 
             incluindo as informações da bula de como usar e para que serve o medicamento, 
             sem adicionar quaisquer outros pontos que não sejam fatais 
             caso não sejam explicados, caso a pessoa que será medicada não 
             saiba, deixe o aviso de que só pode ser usado sob 
             recomendações médicas.""");
      final imageParts = [
        DataPart('image/jpeg', imageBytes),
      ];
      final response = await model.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);
      logger.i(response.text);
      String explicationMedicine =
          response.text?.replaceAll('*', '') ?? 'Erro, sem resposta';
      await _speak(explicationMedicine);
      // Extract the medicine name from the response text
      String? nameMedicine = _extractMedicineName(explicationMedicine);

      if (nameMedicine == null) {
        // If the medicine name is not found, make a subsequent call to refine the information
        final refinePrompt = TextPart(
            "Extrair o nome do remedio da seguinte explicação, apenas o nome: $explicationMedicine");
        final refineResponse = await model.generateContent([
          Content.multi([refinePrompt])
        ]);
        nameMedicine = refineResponse.text?.replaceAll('*', '') ?? 'Error';
      }

      logger.i('Medicine Name: $nameMedicine');
    } catch (e) {
      logger.e('VOICE Error analyzing picture:', error: '$e');
      _speak("Erro ao analisar a imagem.");
    }
  }

  String? _extractMedicineName(String text) {
    // Use a regular expression to extract the medicine name
    final RegExp nameRegExp = RegExp(r'name\s*:\s*(\w+)', caseSensitive: false);
    final match = nameRegExp.firstMatch(text);
    return match?.group(1);
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
