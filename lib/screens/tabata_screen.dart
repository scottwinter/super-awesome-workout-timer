import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:super_awesome_workout_timer/services/sound_effects.dart';
import 'package:super_awesome_workout_timer/widgets/wheel_selector.dart';

enum TabataPhase { initial, work, rest, finished }

class TabataScreen extends StatefulWidget {
  const TabataScreen({super.key});

  @override
  State<TabataScreen> createState() => _TabataScreenState();
}

class _TabataScreenState extends State<TabataScreen> {
  // --- Settings ---
  int _initialWorkSeconds = 20;
  int _initialRestSeconds = 10;
  int _initialRounds = 8;

  // --- State ---
  Timer? _timer;
  TabataPhase _currentPhase = TabataPhase.initial;
  int _currentRound = 1;
  late int _secondsRemaining;

  // --- Countdown State ---
  Timer? _countdownTimer;
  bool _isCountdown = false;
  int _countdownSeconds = 10;

  // --- Controllers & Players ---
  late FixedExtentScrollController _workController;
  late FixedExtentScrollController _restController;
  late FixedExtentScrollController _roundsController;

  @override
  void initState() {
    super.initState();
    SoundEffects().init();

    _secondsRemaining = _initialWorkSeconds;

    _workController = FixedExtentScrollController(
      initialItem: 60 - _initialWorkSeconds,
    );

    _restController = FixedExtentScrollController(
      initialItem: 60 - _initialRestSeconds,
    );

    _roundsController = FixedExtentScrollController(
      initialItem: 20 - _initialRounds,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _workController.dispose();
    _restController.dispose();
    _roundsController.dispose();
    SoundEffects().dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isCountdown = true;

      _countdownSeconds = 10;
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
      _currentRound = 1;

      _currentPhase = TabataPhase.work;

      _secondsRemaining = _initialWorkSeconds;
    });
    _startPeriodicTimer();
  }

  void _pauseTimer() {
    _timer?.cancel();

    WakelockPlus.disable();

    setState(() {}); // To update button state
  }

  void _resumeTimer() {
    WakelockPlus.enable();

    _startPeriodicTimer();
  }

  void _resetTimer() {
    _timer?.cancel();

    _countdownTimer?.cancel();

    WakelockPlus.disable();

    setState(() {
      _currentPhase = TabataPhase.initial;

      _currentRound = 1;

      _secondsRemaining = _initialWorkSeconds;

      _isCountdown = false;
    });
  }

  void _startPeriodicTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
        if (_secondsRemaining <= 3) {
          SoundEffects().play(SoundEffect.beep);
        }
      } else {
        // Timer finished, decide next phase

        if (_currentPhase == TabataPhase.work) {
          if (_currentRound < _initialRounds) {
            // Go to Rest
            SoundEffects().play(SoundEffect.go);
            setState(() {
              _currentPhase = TabataPhase.rest;

              _secondsRemaining = _initialRestSeconds;
            });
          } else {
            // Finished all rounds
            _timer?.cancel();
            WakelockPlus.disable();
            setState(() => _currentPhase = TabataPhase.finished);
          }
        } else if (_currentPhase == TabataPhase.rest) {
          // Go to next Work round
          SoundEffects().play(SoundEffect.go);
          setState(() {
            _currentRound++;

            _currentPhase = TabataPhase.work;

            _secondsRemaining = _initialWorkSeconds;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final phaseText = _currentPhase.toString().split('.').last.toUpperCase();

    final phaseColor = _currentPhase == TabataPhase.work
        ? Colors.green
        : Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(title: const Text('Tabata Timer')),

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
                    ).textTheme.displayLarge?.copyWith(fontSize: 150),
                  ),
                ],
              )
            else if (_currentPhase == TabataPhase.initial)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  WheelSelector(
                    label: 'Work',
                    controller: _workController,
                    maxValue: 60,
                    onSelectedItemChanged: (value) => setState(() {
                      _initialWorkSeconds = value == 0 ? 1 : value;
                      _secondsRemaining = _initialWorkSeconds;
                    }),
                    height: 100,
                    width: 70,
                    itemExtent: 40,
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  WheelSelector(
                    label: 'Rest',
                    controller: _restController,
                    maxValue: 60,
                    onSelectedItemChanged: (value) => setState(
                      () => _initialRestSeconds = value == 0 ? 1 : value,
                    ),
                    height: 100,
                    width: 70,
                    itemExtent: 40,
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  WheelSelector(
                    label: 'Rounds',
                    controller: _roundsController,
                    maxValue: 20,
                    onSelectedItemChanged: (value) =>
                        setState(() => _initialRounds = value == 0 ? 1 : value),
                    height: 100,
                    width: 70,
                    itemExtent: 40,
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    _currentPhase == TabataPhase.finished ? 'DONE' : phaseText,

                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(color: phaseColor),
                  ),

                  Text(
                    '$_secondsRemaining',

                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 150,

                      color: phaseColor,
                    ),
                  ),

                  Text(
                    'Round $_currentRound of $_initialRounds',

                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            if ((_currentPhase == TabataPhase.initial ||
                    _currentPhase == TabataPhase.finished) &&
                !_isCountdown)
              FloatingActionButton.extended(
                heroTag: 'start_button',

                onPressed: _startTimer,

                label: const Text('Start'),

                icon: const Icon(Icons.play_arrow),
              )
            else ...[
              if (!_isCountdown) ...[
                FloatingActionButton.extended(
                  heroTag: 'pause_resume_button',

                  onPressed: () {
                    if (_timer?.isActive ?? false) {
                      _pauseTimer();
                    } else {
                      _resumeTimer();
                    }
                  },

                  label: Text((_timer?.isActive ?? false) ? 'Pause' : 'Resume'),

                  icon: Icon(
                    (_timer?.isActive ?? false)
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                ),

                const SizedBox(width: 20),

                FloatingActionButton(
                  heroTag: 'reset_button',

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
