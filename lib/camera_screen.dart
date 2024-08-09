import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logger/logger.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final Function(String) onPictureTaken;

  const CameraScreen(
      {super.key, required this.camera, required this.onPictureTaken});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
    _flutterTts = FlutterTts();
    _speak("The camera is ready. Tap on screen to take a picture.");
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      // Save the image to local storage or do something with it
      loggerNoStack.i('CAMERA: Picture taken: ${image.path}');
      _speak("Picture taken successfully. Analyzing the picture now.");
      widget.onPictureTaken(image.path);
    } catch (e) {
      logger.e('CAMERA: Error taking picture:', error: '$e');
      Logger(printer: SimplePrinter(colors: true)).t('Camera falhou');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a Picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GestureDetector(
              onTap: _takePicture,
              child: CameraPreview(_controller),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
