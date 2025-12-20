import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class EmomScreen extends StatefulWidget {
  const EmomScreen({super.key});

  @override
  State<EmomScreen> createState() => _EmomScreenState();
}

class _EmomScreenState extends State<EmomScreen> {
  // --- Settings ---
  int _initialMinutes = 10;

  // --- State ---
  Timer? _mainTimer;
  bool _isTimerActive = false;
  bool _isTimerStarted = false; // To track if the timer has ever been started
  bool _isFinished = false;
  int _currentMinute = 1;
  int _secondsRemainingInMinute = 60;

  // --- Countdown State ---
  Timer? _countdownTimer;
  bool _isCountdown = false;
  int _countdownSeconds = 10;

  // --- Controllers & Players ---
  late FixedExtentScrollController _minutesController;
  late final SoLoud _soloud;
  AudioSource? _beepSound;
  AudioSource? _goSound;

  @override
  void initState() {
    super.initState();
    _initSoLoud();
    _minutesController = FixedExtentScrollController(
      initialItem: 30 - _initialMinutes,
    );
  }

  Future<void> _initSoLoud() async {
    _soloud = SoLoud.instance;
    await _soloud.init();
    _soloud.setGlobalVolume(4.0);
    await _loadSounds();
  }

  Future<void> _loadSounds() async {
    _beepSound = await _soloud.loadAsset('assets/sounds/count-beep.mp3');
    _goSound = await _soloud.loadAsset('assets/sounds/go-beep.mp3');
  }

  @override
  void dispose() {
    _mainTimer?.cancel();
    _countdownTimer?.cancel();
    _minutesController.dispose();
    _soloud.deinit();
    WakelockPlus.disable();
    super.dispose();
  }

  void _playSound(String soundPath) async {
    if (soundPath.contains('count-beep')) {
      if (_beepSound != null) {
        _soloud.play(_beepSound!);
      }
    } else if (soundPath.contains('go-beep')) {
      if (_goSound != null) {
        _soloud.play(_goSound!);
      }
    }
  }

  void _startTimer() {
    setState(() {
      _isTimerStarted = true;
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
          _playSound('sounds/count-beep.mp3');
        }
        setState(() => _countdownSeconds--);
      } else {
        _countdownTimer?.cancel();
        setState(() => _isCountdown = false);
        _playSound('sounds/go-beep.mp3');
        _startMainTimer();
      }
    });
  }

  void _startMainTimer() {
    WakelockPlus.enable();
    setState(() {
      _currentMinute = 1;
      _secondsRemainingInMinute = 60;
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
      _currentMinute = 1;
      _secondsRemainingInMinute = 60;
      _isCountdown = false;
    });
  }

  void _startMainPeriodicTimer() {
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemainingInMinute > 1) {
        if (_secondsRemainingInMinute <= 4) {
          // Beep for 3, 2, 1
          _playSound('sounds/count-beep.mp3');
        }
        setState(() => _secondsRemainingInMinute--);
      } else {
        // End of a minute
        _playSound('sounds/go-beep.mp3');
        if (_currentMinute < _initialMinutes) {
          setState(() {
            _currentMinute++;
            _secondsRemainingInMinute = 60;
          });
        } else {
          // End of the workout
          _mainTimer?.cancel();
          WakelockPlus.disable();

          setState(() {
            _isTimerActive = false;
            _isFinished = true;
            _secondsRemainingInMinute = 0;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EMOM Timer')),

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
            else if (!_isTimerStarted)
              Column(
                children: [
                  Text(
                    'Every Minute on the Minute',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'Set Duration (minutes)',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    width: 100,
                    child: ListWheelScrollView.useDelegate(
                      useMagnifier: true,
                      magnification: 1.3,
                      diameterRatio: 1.3,
                      perspective: 0.002,

                      overAndUnderCenterOpacity: 0.5,

                      controller: _minutesController,

                      itemExtent: 50,

                      physics: const FixedExtentScrollPhysics(),

                      onSelectedItemChanged: (index) => setState(() {
                        HapticFeedback.selectionClick();

                        _initialMinutes = 30 - index;
                      }),

                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) => Center(
                          child: Text(
                            '${30 - index}',

                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),

                        childCount: 30,
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    _isFinished
                        ? 'DONE'
                        : 'Minute $_currentMinute of $_initialMinutes',

                    style: Theme.of(context).textTheme.displaySmall,
                  ),

                  Text(
                    '$_secondsRemainingInMinute',

                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 150,

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
