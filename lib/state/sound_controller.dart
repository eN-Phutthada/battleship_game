import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class SoundController extends GetxController {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _uiPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _firePlayer = AudioPlayer();

  bool isBgmMuted = false;
  bool isSfxMuted = false;

  @override
  void onInit() {
    super.onInit();
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void onClose() {
    _bgmPlayer.dispose();
    _uiPlayer.dispose();
    _sfxPlayer.dispose();
    _firePlayer.dispose();
    super.onClose();
  }

  // --- การตั้งค่าเปิด/ปิดเสียง ---

  void toggleBgm() {
    isBgmMuted = !isBgmMuted;
    if (isBgmMuted) {
      _bgmPlayer.pause();
    } else {
      _bgmPlayer.resume();
    }
    update();
  }

  void toggleSfx() {
    isSfxMuted = !isSfxMuted;
    update();
  }

  // --- Music (BGM) ---

  Future<void> playBGM() async {
    if (!isBgmMuted) {
      await _bgmPlayer.play(AssetSource('sounds/bgm.mp3'));
    }
  }

  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
  }

  // --- Sound Effects (SFX) ---

  Future<void> _playSFX(AudioPlayer player, String fileName) async {
    if (isSfxMuted) return;
    await player.stop(); // หยุดเสียงเก่าที่อาจจะค้างอยู่ของ Player ตัวนั้น
    await player.play(AssetSource('sounds/$fileName'));
  }

  // 🖱️ เสียง UI
  void playClick() => _playSFX(_uiPlayer, 'click.ogg'); // เสียงคลิกปุ่มทั่วไป
  void playLock() => _playSFX(_uiPlayer, 'lock.ogg'); // เสียงล็อกเป้าหมาย
  void playError() =>
      _playSFX(_uiPlayer, 'error.ogg'); // เสียง Error (ยิงซ้ำ, วางไม่ได้)
  void playRadar() => _playSFX(_uiPlayer, 'radar.mp3'); // เสียงสแกนตอนเริ่มเกม

  // 💣 เสียงแอคชั่นในเกม
  void playFire() => _playSFX(_firePlayer, 'fire.mp3'); // เสียงปืนใหญ่ตอนกดยิง
  void playHit() => _playSFX(_sfxPlayer, 'hit.ogg'); // เสียงระเบิด (โดน)
  void playMiss() => _playSFX(_sfxPlayer, 'miss.mp3'); // เสียงน้ำกระจาย (พลาด)

  // 🏆 เสียงจบเกม (ให้ไปเล่นที่ _bgmPlayer เพื่อให้มันไปแทนที่เพลงพื้นหลังเดิมเลย)
  void playWin() async {
    _bgmPlayer.setReleaseMode(ReleaseMode.stop); // ไม่ต้องวนลูป
    if (!isSfxMuted) await _bgmPlayer.play(AssetSource('sounds/win.mp3'));
  }

  void playLose() async {
    _bgmPlayer.setReleaseMode(ReleaseMode.stop); // ไม่ต้องวนลูป
    if (!isSfxMuted) await _bgmPlayer.play(AssetSource('sounds/lose.mp3'));
  }
}
