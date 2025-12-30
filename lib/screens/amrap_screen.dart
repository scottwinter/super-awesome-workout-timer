import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import 'package:super_awesome_workout_timer/configs/constants.dart';
import 'package:super_awesome_workout_timer/services/sound_effects.dart';
import 'package:super_awesome_workout_timer/widgets/wheel_selector.dart';

class AmrapScreen extends StatefulWidget {
  const AmrapScreen({super.key});

  @override
  State<AmrapScreen> createState() => _AmrapScreenState();
}

class _AmrapScreenState extends State<AmrapScreen> {
  // --- Settings ---
  int _totalMinutes = AppConstants.defaultAmrapMinutes;

  // --- State ---
  Timer? _mainTimer;
  bool _isTimerActive = false;
  bool _isTimerStarted = false; // To track if the timer has ever been started
  bool _isFinished = false;
  int _elapsedSeconds = 0;

  // --- Countdown State ---
  Timer? _countdownTimer;
  bool _isCountdown = false;
  int _countdownSeconds = AppConstants.defaultCountdownSeconds;

  // --- Controllers & Players ---
  late FixedExtentScrollController _minutesController;

  @override
  void initState() {
    super.initState();
    SoundEffects().init();
    _minutesController = FixedExtentScrollController(
      initialItem: 30 - _totalMinutes,
    );
  }

  @override
  void dispose() {
    _mainTimer?.cancel();
    _countdownTimer?.cancel();
    _minutesController.dispose();
    SoundEffects().dispose();
    WakelockPlus.disable();
    super.dispose();
  }

    void _startTimer() {

      setState(() {

        _isTimerStarted = true;

  

        _isCountdown = true;

  

        _countdownSeconds = AppConstants.defaultCountdownSeconds;

      });

  

      _startCountdown();

    }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 1) {
        if (_countdownSeconds <= 4) {
          // Beep for 3, 2, 1
          SoundEffects().play(SoundEffect.beep);
        }

        setState(() => _countdownSeconds--);
      } else {
        _countdownTimer?.cancel();
        setState(() => _isCountdown = false);
        SoundEffects().play(SoundEffect.go);
        _startMainTimer();
      }
    });
  }

  void _startMainTimer() {
    WakelockPlus.enable();

    setState(() {
      _elapsedSeconds = 0;
      _isTimerActive = true;
      _isFinished = false;
    });
    _startMainPeriodicTimer();
  }

  void _pauseTimer() {
    _mainTimer?.cancel();
    WakelockPlus.disable();
    setState(() {
      _isTimerActive = false;
    });
  }

  void _resumeTimer() {
    WakelockPlus.enable();

    setState(() {
      _isTimerActive = true;
    });

    _startMainPeriodicTimer();
  }

  void _resetTimer() {
    _mainTimer?.cancel();
    _countdownTimer?.cancel();
    WakelockPlus.disable();

    setState(() {
      _isTimerStarted = false;
      _isTimerActive = false;
      _isFinished = false;
      _elapsedSeconds = 0;
      _isCountdown = false;
    });
  }

  void _startMainPeriodicTimer() {
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_elapsedSeconds < _totalMinutes * 60) {
        setState(() => _elapsedSeconds++);
      } else {
        // End of the workout

        _mainTimer?.cancel();
        WakelockPlus.disable();

        setState(() {
          _isTimerActive = false;
          _isFinished = true;
        });
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AMRAP Timer')),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            if (_isCountdown)
              Column(
                children: [
                  Text(
                    'Get Ready...',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),

                                    Text(

                                      '$_countdownSeconds',

                  

                                      style: Theme.of(

                                        context,

                                      ).textTheme.displayLarge?.copyWith(fontSize: AppConstants.countdownFontSize),

                                    ),
                ],
              )
            else if (!_isTimerStarted)
              Column(
                children: [
                  Text(
                    'As Many Rounds As Possible',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),
                  WheelSelector(
                    label: 'Set Duration (minutes)',
                    controller: _minutesController,
                    maxValue: 30,
                    onSelectedItemChanged: (value) {
                      setState(() {
                        _totalMinutes = value;
                      });
                    },
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    _isFinished ? 'DONE' : 'Time Remaining',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),

                  Text(
                    _formatTime((_totalMinutes * 60) - _elapsedSeconds),
                                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                          fontSize: AppConstants.timerFontSizeLarge,
                    
                                          color: _isFinished ? Colors.red : null,
                                        ),
                  ),
                ],
              ),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            if (!_isTimerStarted)
              FloatingActionButton.extended(
                heroTag: 'start_button',
                onPressed: _startTimer,
                label: const Text('Start'),
                icon: const Icon(Icons.play_arrow),
              )
            else if (_isFinished)
              FloatingActionButton.extended(
                heroTag: 'reset_button_finished',
                onPressed: _resetTimer,
                label: const Text('Reset'),
                icon: const Icon(Icons.refresh),
              )
            else ...[
              if (!_isCountdown) ...[
                FloatingActionButton.extended(
                  heroTag: 'pause_resume_button',
                  onPressed: () {
                    if (_isTimerActive) {
                      _pauseTimer();
                    } else {
                      _resumeTimer();
                    }
                  },

                  label: Text(_isTimerActive ? 'Pause' : 'Resume'),
                  icon: Icon(_isTimerActive ? Icons.pause : Icons.play_arrow),
                ),

                const SizedBox(width: 20),

                FloatingActionButton(
                  heroTag: 'reset_button_active',
                  onPressed: _resetTimer,
                  tooltip: 'Reset',
                  child: const Icon(Icons.refresh),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
