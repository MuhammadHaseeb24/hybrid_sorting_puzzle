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

  static const String _musicAsset = 'assets/sounds/bg_music.mp3';
  Uint8List? _musicBytes;
  bool _musicPlayerOpen = false;
  bool _musicWanted = false; // true while music should be looping
  bool _musicPaused = false;

  bool soundEnabled = true;
  bool musicEnabled = true;

  Future<void> init() async {
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

  // ========== SOUND EFFECTS (small player pool so sounds can overlap) ==========
  final List<AudioPlayer> _pool = List.generate(4, (_) => AudioPlayer());
  int _poolIdx = 0;

  Future<void> _play(String file, {double volume = 0.8}) async {
    if (!soundEnabled) return;
    try {
      final p = _pool[_poolIdx];
      _poolIdx = (_poolIdx + 1) % _pool.length;
      await p.stop();
      await p.setVolume(volume);
      await p.play(AssetSource('sounds/$file'));
    } catch (e) {
      debugPrint('$file sfx error: $e');
    }
  }

  Future<void> playSelect() => _play('select.mp3');
  Future<void> playPour() => _play('pour.mp3', volume: 0.9);
  Future<void> playWin() => _play('win.mp3', volume: 1.0);
  Future<void> playLose() => _play('lose.mp3');
  Future<void> playClick() => _play('click.mp3', volume: 0.7);
  Future<void> playStar() => _play('star.mp3');

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
    for (final p in _pool) {
      await p.dispose();
    }
  }
}
