import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:super_awesome_workout_timer/configs/constants.dart';
import 'package:super_awesome_workout_timer/services/sound_effects.dart';
import 'package:super_awesome_workout_timer/widgets/wheel_selector.dart';

class PyramidScreen extends StatefulWidget {
  const PyramidScreen({super.key});

  @override
  State<PyramidScreen> createState() => _PyramidScreenState();
}

class _PyramidScreenState extends State<PyramidScreen> {
  // --- Settings ---
  int _peakRound = AppConstants.defaultPyramidPeakRound;

  // --- State ---
  Timer? _timer;
  Timer? _flashTimer;
  bool _isTimerActive = false;
  bool _isTimerStarted = false;
  bool _isFinished = false;
  int _elapsedSeconds = 0;
  bool _isTimeVisible = true;

  // --- Pyramid Round State ---
  int _currentRound = 1;
  bool _isAscending = true;
  bool _isPyramidFinished = false;

  // --- Countdown State ---
  Timer? _countdownTimer;
  bool _isCountdown = false;
  int _countdownSeconds = AppConstants.defaultCountdownSeconds;

  // --- Controllers & Players ---
  late FixedExtentScrollController _peakRoundController;

  @override
  void initState() {
    super.initState();
    SoundEffects().init();
    // Let's allow setting a peak round up to 20.
    _peakRoundController =
        FixedExtentScrollController(initialItem: 20 - _peakRound);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flashTimer?.cancel();
    _countdownTimer?.cancel();
    _peakRoundController.dispose();
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
    _startPeriodicTimer();
  }

  void _pauseTimer() {
    _timer?.cancel();
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
    _startPeriodicTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _flashTimer?.cancel();
    _countdownTimer?.cancel();
    WakelockPlus.disable();
    setState(() {
      _isTimerStarted = false;
      _isTimerActive = false;
      _isFinished = false;
      _elapsedSeconds = 0;
      _isTimeVisible = true;
      _currentRound = 1;
      _isAscending = true;
      _isPyramidFinished = false;
      _isCountdown = false;
    });
  }

  void _finishTimer() {
    _timer?.cancel();
    WakelockPlus.disable();
    setState(() {
      _isFinished = true;
      _isTimerActive = false;
    });
    int flashCount = 0;
    _flashTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (flashCount >= 15) {
        timer.cancel();
        setState(() {
          _isTimeVisible = true; // Ensure it's visible at the end
        });
        return;
      }
      setState(() {
        _isTimeVisible = !_isTimeVisible;
      });
      flashCount++;
    });
  }

  void _nextRound() {
    if (_isPyramidFinished) return;

    setState(() {
      if (_isAscending) {
        if (_currentRound < _peakRound) {
          _currentRound++;
        } else {
          _isAscending = false;
          _currentRound--;
        }
      } else {
        if (_currentRound > 1) {
          _currentRound--;
        } else {
          _finishTimer();
        }
      }
    });
  }

  void _startPeriodicTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsedSeconds++);
    });
  }

  String _formatTime(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pyramid Timer')),
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
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: AppConstants.countdownFontSize,
                        ),
                  ),
                ],
              )
            else if (!_isTimerStarted)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WheelSelector(
                    label: 'Set the Top of the Pyramid',
                    controller: _peakRoundController,
                    maxValue: 20,
                    magnification: AppConstants.pyramidWheelMagnification,
                    onSelectedItemChanged: (value) {
                      setState(() {
                        _peakRound = value;
                      });
                    },
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    _isFinished
                        ? 'PYRAMID COMPLETE'
                        : 'Round $_currentRound',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(color: _isFinished ? Colors.red : null),
                  ),
                  const SizedBox(height: 10),
                  AnimatedOpacity(
                    opacity: _isTimeVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _formatTime(_elapsedSeconds),
                      style:
                          Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: AppConstants.timerFontSizeMedium,
                                color: _isFinished ? Colors.red : null,
                              ),
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
                // Pause/Resume Button
                FloatingActionButton.extended(
                  heroTag: 'pause_resume_button',
                  onPressed: _isTimerActive ? _pauseTimer : _resumeTimer,
                  label: Text(_isTimerActive ? 'Pause' : 'Resume'),
                  icon: Icon(_isTimerActive ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 10),
                // Round Complete Button
                FloatingActionButton.extended(
                  heroTag: 'round_button',
                  onPressed: _nextRound,
                  backgroundColor: _isFinished ? Colors.grey : Colors.red,
                  label: Text(
                      !_isAscending && _currentRound == 1 ? 'Finish' : 'Round'),
                  icon: const Icon(Icons.track_changes),
                ),
                const SizedBox(width: 10),
                // Reset Button
                FloatingActionButton(
                  heroTag: 'reset_button_active',
                  onPressed: _resetTimer,
                  tooltip: 'Reset',
                  child: const Icon(Icons.refresh),
                ),
              ]
            ]
          ],
        ),
      ),
    );
  }
}