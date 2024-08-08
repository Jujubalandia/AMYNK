import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'camera_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

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
  final String _apiKey =
      'AIzaSyCQR7C0s-JZ22MNHvV3yTKucHO4dWTGMDs'; // Replace with your API key

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
        print('onError: $val');
        _listenContinuously();
      },
    );
    if (available) {
      _speech.listen(
        onResult: (val) => setState(() {
          _text = val.recognizedWords;
          if (val.hasConfidenceRating && val.confidence > 0) {
            print('Recognized: $_text');
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
      print('No cameras available');
    }
  }

  Future<void> _analyzePicture(String imagePath) async {
    _speak("Analizando a imagem.");
    /*try {
      final bytes = File(imagePath).readAsBytesSync();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(
            'https://api.google.com/gemini/v1/analyze'), // Replace with the actual API endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'image': base64Image,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final description = result['description'];
        _speak("The picture shows: $description");
      } else {
        print('Failed to analyze picture: ${response.body}');
        _speak("Failed to analyze the picture.");
      }
    } catch (e) {
      print('##### VOICE FILE Error analyzing picture: $e');
      _speak("Error analyzing the picture.");
    }
    */
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
