import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:super_awesome_workout_timer/services/sound_effects.dart';

class ForTimeScreen extends StatefulWidget {
  const ForTimeScreen({super.key});

  @override
  State<ForTimeScreen> createState() => _ForTimeScreenState();
}

class _ForTimeScreenState extends State<ForTimeScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  int _roundCount = 0;

  // --- Countdown State ---
  Timer? _countdownTimer;
  bool _isCountdown = false;
  int _countdownSeconds = 10;
  bool _isTimerStarted = false; // To track if the timer has ever been started

  @override
  void initState() {
    super.initState();
    SoundEffects().init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    SoundEffects().dispose();
    WakelockPlus.disable();
    super.dispose();
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
          SoundEffects().play(SoundEffect.beep);
        } 
        setState(() => _countdownSeconds--);
      } else {
        _countdownTimer?.cancel();
        setState(() => _isCountdown = false);
        SoundEffects().play(SoundEffect.go);
        _toggleTimer(); // This will now start the main timer
      }
    });
  }

  void _toggleTimer() {
    if (!_isTimerStarted) {
      _startTimer();
      return;
    }

    if (_isRunning) {
      _timer?.cancel();
      WakelockPlus.disable();
    } else {
      WakelockPlus.enable();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
        });
      });
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    WakelockPlus.disable();
    setState(() {
      _elapsedSeconds = 0;
      _isRunning = false;
      _roundCount = 0;
      _isTimerStarted = false;
      _isCountdown = false;
    });
  }

  void _addRound() {
    if (_isRunning) {
      setState(() {
        _roundCount++;
      });
    }
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
      appBar: AppBar(
        title: const Text('For Time'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
            else
              Column(
                children: [
                  Text(
                    'Rounds: $_roundCount',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontSize: 80),
                  ),
                ],
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            if (!_isTimerStarted || _isRunning || !_isTimerStarted && !_isCountdown)
              FloatingActionButton.extended(
                heroTag: 'fortime_toggle',
                onPressed: _isCountdown ? null : _toggleTimer,
                label: Text(_isRunning ? 'Pause' : 'Start'),
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
              ),
            if (_isTimerStarted && !_isRunning && !_isCountdown)
              FloatingActionButton.extended(
                heroTag: 'fortime_resume',
                onPressed: _toggleTimer,
                label: const Text('Resume'),
                icon: const Icon(Icons.play_arrow),
              ),
            if (!_isCountdown)
              FloatingActionButton.extended(
                heroTag: 'fortime_round',
                onPressed: _addRound,
                backgroundColor: Colors.red,
                label: const Text('Round'),
                icon: const Icon(Icons.track_changes),
              ),
            if (!_isCountdown)
              FloatingActionButton(
                heroTag: 'fortime_reset',
                onPressed: _resetTimer,
                child: const Icon(Icons.refresh),
              ),
          ],
        ),
      ),
    );
  }
}
