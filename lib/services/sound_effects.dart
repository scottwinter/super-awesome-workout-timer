import 'package:flutter_soloud/flutter_soloud.dart';

enum SoundEffect {
  beep,
  go,
}

class SoundEffects {
  static final SoundEffects _instance = SoundEffects._internal();
  factory SoundEffects() => _instance;

  SoundEffects._internal();

  late final SoLoud _soloud;
  AudioSource? _beepSound;
  AudioSource? _goSound;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    _soloud = SoLoud.instance;
    await _soloud.init();
    _soloud.setGlobalVolume(4.0);
    await _loadSounds();
    _isInitialized = true;
  }

  Future<void> _loadSounds() async {
    _beepSound = await _soloud.loadAsset('assets/sounds/count-beep.mp3');
    _goSound = await _soloud.loadAsset('assets/sounds/go-beep.mp3');
  }

  void play(SoundEffect sound) {
    if (!_isInitialized) return;

    switch (sound) {
      case SoundEffect.beep:
        if (_beepSound != null) {
          _soloud.play(_beepSound!);
        }
        break;
      case SoundEffect.go:
        if (_goSound != null) {
          _soloud.play(_goSound!);
        }
        break;
    }
  }

  void dispose() {
    if (!_isInitialized) return;
    _soloud.deinit();
    _isInitialized = false;
  }
}
