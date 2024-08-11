import 'package:logger/logger.dart';

class ScheduleMedicine {
  final Logger logger;

  ScheduleMedicine({required this.logger});

  void logSchedule(String medicineName, String time) {
    logger.i('Agendar: Remédio $medicineName às $time');
  }
}
