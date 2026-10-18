import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool soundEnabled = true;
  bool musicEnabled = true;

  Future<void> init() async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.35);
      await _sfxPlayer.setVolume(0.8);
    } catch (e) {
      debugPrint('SoundService init error: $e');
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!musicEnabled) return;
    try {
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource('sounds/bg_music.mp3'));
    } catch (e) {
      debugPrint('BG music error: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (_) {}
  }

  Future<void> resumeBackgroundMusic() async {
    if (!musicEnabled) return;
    try {
      await _musicPlayer.resume();
    } catch (_) {}
  }

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
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}