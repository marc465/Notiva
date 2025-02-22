import 'package:flutter/material.dart';

mixin ProvidersDeleteMixin on ChangeNotifier {
  bool isTimerStart = false;
  double progress = 0;
  double remainingTime = 5;
  String get deletionMessage;
  
  void deleteCancel();
}