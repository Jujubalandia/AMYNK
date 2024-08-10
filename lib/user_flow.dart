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
        logger.e('onError: $val');
        _listenContinuously();
      },
      debugLogging: true,
    );

    if (available) {
      _speech.listen(
        onResult: (val) => setState(() {
          _text = val.recognizedWords;
          if (val.hasConfidenceRating && val.confidence > 0) {
            loggerNoStack.i('Recognized: $_text');
            if (_text.toLowerCase().contains('ver  remédio')) {
              _openCamera();
            } else if (_text.toLowerCase().contains('parar')) {
              _stopListening();
            } else if (_text.toLowerCase().contains('iniciar')) {
              _listenContinuously();
            } else if (_text.toLowerCase().contains('lembrar')) {
              _rememberMedicineSchedules();
            } else if (_text.toLowerCase().contains('agendar')) {
              _medicineSchedule();
            }
          }
        }),
      );
    }
  }

  void _medicineSchedule() {
    // TO DO: implement the logic to display the medicine schedules
    _speak("Agendar remedio paraa lembrar depois");
    loggerNoStack.i('medicine schedules...');
  }

  void _rememberMedicineSchedules() {
    // TO DO: implement the logic to remember medicine schedules
    _speak("Listando remédios agendados");
    loggerNoStack.i('Remembering medicine schedules...');
    // TO DO: implement the logic to remember medicine schedules
  }

  void _stopListening() {
    _speak("Parando de ouvir comandos, para ativar aperte a tela novamente.");
    _speech.stop();
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
             com a menor quantidade de linhas possível sendo bem objetivo e 
             simples como se estivesse falando com uma vovó bem velhinha, 
             incluindo informações da bula de como usar e para que serve, 
             sem adicionar quaisquer outros pontos que não sejam fatais 
             caso não sejam explicados, caso a vovó que será medicada não 
             saiba, deixe o aviso de que só pode ser usado sob 
             recomendações médicas.""");
      final imageParts = [
        DataPart('image/jpeg', imageBytes),
      ];
      final response = await model.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);
      logger.i(response.text);
      _speak(response.text ?? 'Erro, sem resposta');

      if (response.text != null) {
        _speak("Deseja agendar o horario de uso?");
        _listenContinuously();
      }
    } catch (e) {
      loggerNoStack.e('VOICE Error analyzing picture:', error: '$e');
      _speak("Erro ao analisar a imagem.");
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
          //TO-DO: implement the logic to Speak on Tap on screen
        ),
      ),
    );
  }
}
