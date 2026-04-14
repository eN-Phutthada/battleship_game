import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../screens/main_menu.dart';
import '../../utils/constants.dart';
import '../../state/sound_controller.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  void _changeLanguage(String langCode) {
    final sound = Get.find<SoundController>();
    sound.playClick();
    sound.vibrateLight();

    final localeMap = {
      'en': const Locale('en', 'US'),
      'th': const Locale('th', 'TH'),
      'es': const Locale('es', 'ES'),
      'ja': const Locale('ja', 'JP'),
    };
    Get.updateLocale(localeMap[langCode] ?? const Locale('en', 'US'));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: GetBuilder<SoundController>(builder: (sound) {
        return Container(
          width: 450,
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.paper,
            border: Border.all(color: AppColors.ink, width: 3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black26, offset: Offset(8, 8))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune, color: AppColors.ink, size: 28),
                      const SizedBox(width: 10),
                      Text('settings'.tr,
                          style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5)),
                    ],
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon:
                        const Icon(Icons.close, color: AppColors.ink, size: 28),
                    onPressed: () {
                      sound.playClick();
                      Get.back();
                    },
                  ),
                ],
              ),
              const Divider(color: AppColors.ink, thickness: 2, height: 24),

              // --- BODY ---
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. LANGUAGE SECTION
                      _buildSectionTitle(Icons.language, 'language'.tr),
                      const SizedBox(height: 8),
                      CustomSegmentedControl<String>(
                        selectedValue: Get.locale?.languageCode ?? 'en',
                        items: const {
                          'en': 'EN',
                          'th': 'TH',
                          'es': 'ES',
                          'ja': 'JA',
                        },
                        onChanged: _changeLanguage,
                      ),
                      const SizedBox(height: 24),

                      // 2. AUDIO SECTION
                      _buildSectionTitle(Icons.volume_up,
                          'AUDIO'), // สามารถเพิ่มคีย์ใน Translations ภายหลังได้
                      const SizedBox(height: 8),
                      _buildBoxedSection([
                        _buildSliderRow(
                          icon: sound.bgmVolume == 0
                              ? Icons.music_off
                              : Icons.music_note,
                          label: 'bgm_volume'.tr,
                          value: sound.bgmVolume,
                          onChanged: sound.setBgmVolume,
                        ),
                        const Divider(
                            height: 1,
                            color: Colors.black12,
                            indent: 16,
                            endIndent: 16),
                        _buildSliderRow(
                          icon: sound.sfxVolume == 0
                              ? Icons.volume_off
                              : Icons.volume_up,
                          label: 'sfx_volume'.tr,
                          value: sound.sfxVolume,
                          onChanged: (val) {
                            sound.setSfxVolume(val);
                            if (val > 0 && !sound.isSfxMuted) sound.playClick();
                          },
                        ),
                      ]),
                      const SizedBox(height: 24),

                      // 3. SYSTEM SECTION
                      _buildSectionTitle(Icons.vibration,
                          'SYSTEM'), // สามารถเพิ่มคีย์ใน Translations ภายหลังได้
                      const SizedBox(height: 8),
                      _buildBoxedSection([
                        _buildSwitchRow(
                          label: 'haptic_feedback'.tr,
                          value: sound.hapticsEnabled,
                          onChanged: (val) => sound.toggleHaptics(),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),

              // --- FOOTER ---
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ink,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6))),
                  onPressed: () {
                    sound.playClick();
                    Get.back();
                  },
                  child: Text('roger_that'.tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ==========================================
  // WIDGET HELPERS (เพื่อความคลีนของโค้ด)
  // ==========================================

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.ink, size: 16),
        const SizedBox(width: 6),
        Text(title.toUpperCase(),
            style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildBoxedSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ink.withOpacity(0.02),
        border: Border.all(color: AppColors.ink.withOpacity(0.2), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSliderRow(
      {required IconData icon,
      required String label,
      required double value,
      required ValueChanged<double> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                      fontSize: 12)),
              const Spacer(),
              Text('${(value * 100).toInt()}%',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.ink),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: AppColors.ink,
                    inactiveTrackColor: AppColors.ink.withOpacity(0.15),
                    thumbColor: AppColors.paper,
                    overlayColor: AppColors.ink.withOpacity(0.1),
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8, elevation: 4),
                  ),
                  child: Slider(
                    value: value,
                    min: 0.0,
                    max: 1.0,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
      {required String label,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                  fontSize: 12)),
          Switch(
            value: value,
            activeColor: AppColors.paper,
            activeTrackColor: AppColors.ink,
            inactiveThumbColor: AppColors.ink,
            inactiveTrackColor: AppColors.ink.withOpacity(0.15),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
