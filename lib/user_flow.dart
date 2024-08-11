import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'voice_recognition.dart';
import 'image_analyzing.dart';
import 'google_gemini_bloc.dart';
import 'voice_menu.dart';
import 'schedule_medicine.dart';

class UserFlow extends StatefulWidget {
  final String title;

  const UserFlow({super.key, required this.title});

  @override
  State<UserFlow> createState() => _UserFlowState();
}

class _UserFlowState extends State<UserFlow> {
  late VoiceRecognition _voiceRecognition;
  late ImageAnalyzing _imageAnalyzing;
  late ScheduleMedicine _scheduleMedicine;
  late VoiceMenu _voiceMenu;
  late List<CameraDescription> _cameras;
  final String _apiKey = '';

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    final googleGeminiBloc = GoogleGeminiBloc(apiKey: _apiKey);
    _voiceRecognition = VoiceRecognition(onRecognized: _onRecognized);
    _imageAnalyzing = ImageAnalyzing(
        logger: logger,
        flutterTts: _voiceRecognition.flutterTts,
        googleGeminiBloc: googleGeminiBloc);
    _scheduleMedicine = ScheduleMedicine(logger: logger);
    _voiceMenu = VoiceMenu(
      logger: logger,
      flutterTts: _voiceRecognition.flutterTts,
      voiceRecognition: _voiceRecognition,
      imageAnalyzing: _imageAnalyzing,
      scheduleMedicine: _scheduleMedicine,
      context: context,
    );

    _initializeCameras();
    _voiceRecognition.initialize();
    _voiceMenu.initialize();
  }

  void _initializeCameras() async {
    _cameras = await availableCameras();
    _imageAnalyzing.setCameras(_cameras);
  }

  void _onRecognized(String text) {
    setState(() {
      _voiceMenu.onRecognized(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: FlashingRedCross(),
        //TO-DO: implement the logic to Speak on Tap on screen
      ),
    );
  }
}

class FlashingRedCross extends StatefulWidget {
  const FlashingRedCross({super.key});

  @override
  FlashingRedCrossState createState() => FlashingRedCrossState();
}

class FlashingRedCrossState extends State<FlashingRedCross>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CrossPainter(_animation),
      child: Container(),
    );
  }
}

class CrossPainter extends CustomPainter {
  final Animation<double> animation;

  CrossPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    const crossSize = 150.0;
    final waveRadius = animation.value * size.width;

    // Draw the red cross
    canvas.drawRect(
      Rect.fromCenter(center: center, width: crossSize, height: 10),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 10, height: crossSize),
      paint,
    );

    // Draw the circular waves
    for (double i = 0; i < waveRadius; i += 20) {
      paint.color = paint.color.withOpacity(1 - (i / waveRadius));
      canvas.drawCircle(center, i, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
