import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_sound/flutter_sound.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  // Background music -> flutter_sound
  final FlutterSoundPlayer _musicPlayer = FlutterSoundPlayer();
  // Sound effects -> audioplayers
  final AudioPlayer _sfxPlayer = AudioPlayer();

  static const String _musicAsset = 'assets/sounds/bg_music.mp3';
  Uint8List? _musicBytes;
  bool _musicPlayerOpen = false;
  bool _musicWanted = false; // true while music should be looping
  bool _musicPaused = false;

  bool soundEnabled = true;
  bool musicEnabled = true;

  Future<void> init() async {
    try {
      await _sfxPlayer.setVolume(0.8);
    } catch (e) {
      debugPrint('SoundService sfx init error: $e');
    }
    try {
      if (!_musicPlayerOpen) {
        await _musicPlayer.openPlayer();
        _musicPlayerOpen = true;
      }
      await _musicPlayer.setVolume(0.35);
      final data = await rootBundle.load(_musicAsset);
      _musicBytes = data.buffer.asUint8List();
    } catch (e) {
      debugPrint('SoundService music init error: $e');
    }
  }

  // ========== BACKGROUND MUSIC (flutter_sound) ==========
  Future<void> playBackgroundMusic() async {
    if (!musicEnabled) return;
    if (!_musicPlayerOpen || _musicBytes == null) return;
    if (_musicWanted && _musicPlayer.isPlaying) return; // already playing
    _musicWanted = true;
    _musicPaused = false;
    await _startMusicLoop();
  }

  Future<void> _startMusicLoop() async {
    try {
      if (_musicPlayer.isPlaying || _musicPlayer.isPaused) {
        await _musicPlayer.stopPlayer();
      }
      await _musicPlayer.startPlayer(
        fromDataBuffer: _musicBytes,
        codec: Codec.mp3,
        whenFinished: () {
          // flutter_sound has no loop mode, so restart manually.
          if (_musicWanted && musicEnabled && !_musicPaused) {
            _startMusicLoop();
          }
        },
      );
      await _musicPlayer.setVolume(0.35);
    } catch (e) {
      debugPrint('BG music error: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    _musicWanted = false;
    _musicPaused = false;
    try {
      if (_musicPlayerOpen &&
          (_musicPlayer.isPlaying || _musicPlayer.isPaused)) {
        await _musicPlayer.stopPlayer();
      }
    } catch (_) {}
  }

  Future<void> pauseBackgroundMusic() async {
    _musicPaused = true;
    try {
      if (_musicPlayerOpen && _musicPlayer.isPlaying) {
        await _musicPlayer.pausePlayer();
      }
    } catch (_) {}
  }

  Future<void> resumeBackgroundMusic() async {
    if (!musicEnabled) return;
    _musicPaused = false;
    try {
      if (_musicPlayerOpen && _musicPlayer.isPaused) {
        await _musicPlayer.resumePlayer();
      } else if (_musicWanted && !_musicPlayer.isPlaying) {
        await _startMusicLoop();
      }
    } catch (_) {}
  }

  // ========== SOUND EFFECTS ==========
  Future<void> playSelect() async {
    if (!soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/select.mp3'));
    } catch (e) {
      debugPrint('select sfx error: $e');
    }
  }

  Future<void> playPour() async {
    if (!soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/pour.mp3'));
    } catch (e) {
      debugPrint('pour sfx error: $e');
    }
  }

  Future<void> playWin() async {
    if (!soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/win.mp3'));
    } catch (e) {
      debugPrint('win sfx error: $e');
    }
  }

  Future<void> playLose() async {
    if (!soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/lose.mp3'));
    } catch (e) {
      debugPrint('lose sfx error: $e');
    }
  }

  Future<void> playClick() async {
    if (!soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      debugPrint('click sfx error: $e');
    }
  }

  Future<void> playStar() async {
    if (!soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('sounds/star.mp3'));
    } catch (e) {
      debugPrint('star sfx error: $e');
    }
  }

  void setSoundEnabled(bool value) {
    soundEnabled = value;
  }

  void setMusicEnabled(bool value) {
    musicEnabled = value;
    if (value) {
      playBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
  }

  Future<void> dispose() async {
    _musicWanted = false;
    try {
      if (_musicPlayerOpen) {
        await _musicPlayer.closePlayer();
        _musicPlayerOpen = false;
      }
    } catch (_) {}
    await _sfxPlayer.dispose();
  }
}
