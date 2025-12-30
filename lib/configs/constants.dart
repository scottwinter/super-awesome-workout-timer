import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appTitle = 'Super Awesome Workout Timer';
  static const String appShortTitle = 'Workout Timer';
  static const Color seedColor = Colors.lightBlue;

  // Sound Paths
  static const String beepSoundPath = 'assets/sounds/count-beep.mp3';
  static const String goSoundPath = 'assets/sounds/go-beep.mp3';
  static const double globalVolume = 4.0;

  // Timer Defaults
  static const int defaultAmrapMinutes = 10;
  static const int defaultCountdownSeconds = 10;
  static const int defaultEmomMinutes = 10;
  static const int defaultTabataWorkSeconds = 20;
  static const int defaultTabataRestSeconds = 10;
  static const int defaultTabataRounds = 8;
  static const int defaultPyramidPeakRound = 10;
  
  // UI Constants
  static const double countdownFontSize = 150.0;
  static const double timerFontSizeExtraLarge = 150.0;
  static const double timerFontSizeLarge = 100.0;
  static const double timerFontSizeMedium = 80.0;
  static const double defaultWheelMagnification = 1.3;
  static const double pyramidWheelMagnification = 1.7;
}
