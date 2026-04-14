import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SoundController extends GetxController {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _sfxFirePlayer = AudioPlayer();

  // --- Settings State ---
  bool isBgmMuted = false;
  bool isSfxMuted = false;
  double bgmVolume = 0.5; // ความดัง BGM (0.0 - 1.0)
  double sfxVolume = 0.8; // ความดัง SFX (0.0 - 1.0)
  bool hapticsEnabled = true; // ระบบสั่น

  // --- Settings Actions ---
  void setBgmVolume(double vol) {
    bgmVolume = vol;
    _bgmPlayer.setVolume(vol);
    if (vol == 0) {
      isBgmMuted = true;
    } else {
      isBgmMuted = false;
    }
    update();
  }

  void setSfxVolume(double vol) {
    sfxVolume = vol;
    _sfxPlayer.setVolume(vol);
    _sfxFirePlayer.setVolume(vol);
    if (vol == 0) {
      isSfxMuted = true;
    } else {
      isSfxMuted = false;
    }
    update();
  }

  void toggleHaptics() {
    hapticsEnabled = !hapticsEnabled;
    if (hapticsEnabled) HapticFeedback.lightImpact();
    update();
  }

  // ตัวช่วยสั่น (เรียกใช้แทน HapticFeedback โดยตรง เพื่อให้ปิดได้)
  void vibrateLight() {
    if (hapticsEnabled) HapticFeedback.lightImpact();
  }

  void vibrateHeavy() {
    if (hapticsEnabled) HapticFeedback.heavyImpact();
  }

  // --- BGM ---
  Future<void> playBGM() async {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _bgmPlayer.setVolume(bgmVolume);
    if (!isBgmMuted && bgmVolume > 0) {
      await _bgmPlayer.play(AssetSource('sounds/bgm.ogg'));
    }
  }

  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
  }

  // --- SFX ---
  Future<void> _playSFX(AudioPlayer player, String fileName) async {
    if (isSfxMuted || sfxVolume == 0) return;
    await player.stop();
    await player.setVolume(sfxVolume);
    await player.play(AssetSource('sounds/$fileName'));
  }

  void playFire() => _playSFX(_sfxFirePlayer, 'fire.ogg');
  void playHit() => _playSFX(_sfxPlayer, 'hit.ogg');
  void playMiss() => _playSFX(_sfxPlayer, 'miss.ogg');
  void playLock() => _playSFX(_sfxPlayer, 'click.ogg');
  void playError() => _playSFX(_sfxPlayer, 'error.ogg');
  void playWin() => _playSFX(_sfxPlayer, 'win.ogg');
  void playLose() => _playSFX(_sfxPlayer, 'lose.ogg');
  void playClick() => _playSFX(_sfxPlayer, 'click.ogg');
}
