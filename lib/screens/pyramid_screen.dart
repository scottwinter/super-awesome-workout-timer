import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class PyramidScreen extends StatefulWidget {
  const PyramidScreen({super.key});

  @override
  State<PyramidScreen> createState() => _PyramidScreenState();
}

class _PyramidScreenState extends State<PyramidScreen> {
  // --- Settings ---
  int _peakRound = 10;

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
  int _countdownSeconds = 10;

  // --- Controllers & Players ---
  late FixedExtentScrollController _peakRoundController;
  late final SoLoud _soloud;
  AudioSource? _beepSound;
  AudioSource? _goSound;

  @override
  void initState() {
    super.initState();
    _initSoLoud();
    // Let's allow setting a peak round up to 20.
    _peakRoundController =
        FixedExtentScrollController(initialItem: 20 - _peakRound);
  }

  Future<void> _initSoLoud() async {
    _soloud = SoLoud.instance;
    await _soloud.init();
    await _loadSounds();
  }

  Future<void> _loadSounds() async {
    _beepSound = await _soloud.loadAsset('assets/sounds/count-beep.mp3');
    _goSound = await _soloud.loadAsset('assets/sounds/go-beep.mp3');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flashTimer?.cancel();
    _countdownTimer?.cancel();
    _peakRoundController.dispose();
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
                          fontSize: 150,
                        ),
                  ),
                ],
              )
            else if (!_isTimerStarted)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Set the Top of the Pyramid',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 150,
                    width: 100,
                    child: ListWheelScrollView.useDelegate(
                      useMagnifier: true,
                      magnification: 1.7,
                      diameterRatio: 1.3,
                      perspective: 0.002,
                      overAndUnderCenterOpacity: 0.5,
                      controller: _peakRoundController,
                      itemExtent: 50,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          // Max value is 20, so we subtract from that.
                          _peakRound = 20 - index;
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) => Center(
                          child: Text('${20 - index}',
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                        ),
                        childCount: 20, // Allows setting peak from 1 to 20
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
                                fontSize: 80,
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