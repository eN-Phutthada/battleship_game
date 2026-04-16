import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../state/sound_controller.dart';
import '../widgets/shared/animated_paper_bg.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: AnimatedPaperBackground(
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    _buildBackButton(),
                    const SizedBox(width: 16),
                    const Icon(Icons.tune, color: AppColors.ink, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('settings'.tr,
                          style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2)),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(color: AppColors.ink, thickness: 3, height: 1),
              ),

              // --- CONTENT ---
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child: GetBuilder<SoundController>(builder: (sound) {
                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          // 1. LANGUAGE SECTION
                          _buildPaperCard(
                            title: 'language'.tr,
                            icon: Icons.language,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildLanguageControl(),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 2. AUDIO SECTION
                          _buildPaperCard(
                            title: 'AUDIO',
                            icon: Icons.volume_up,
                            child: Column(
                              children: [
                                _buildSliderRow(
                                  icon: sound.bgmVolume == 0
                                      ? Icons.music_off
                                      : Icons.music_note,
                                  label: 'bgm_volume'.tr,
                                  value: sound.bgmVolume,
                                  onChanged: sound.setBgmVolume,
                                ),
                                const Divider(
                                    color: AppColors.ink,
                                    thickness: 2,
                                    height: 1),
                                _buildSliderRow(
                                  icon: sound.sfxVolume == 0
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  label: 'sfx_volume'.tr,
                                  value: sound.sfxVolume,
                                  onChanged: (val) {
                                    sound.setSfxVolume(val);
                                    if (val > 0 && !sound.isSfxMuted) {
                                      sound.playClick();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 3. SYSTEM SECTION
                          _buildPaperCard(
                            title: 'SYSTEM',
                            icon: Icons.vibration,
                            child: _buildSwitchRow(
                              label: 'haptic_feedback'.tr,
                              value: sound.hapticsEnabled,
                              onChanged: (val) => sound.toggleHaptics(),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      onTap: () {
        Get.find<SoundController>().playClick();
        Get.back();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: AppColors.ink, offset: Offset(3, 3))
          ],
        ),
        child: const Icon(Icons.arrow_back, color: AppColors.ink, size: 24),
      ),
    );
  }

  Widget _buildPaperCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            Icon(icon, color: AppColors.ink, size: 22),
            const SizedBox(width: 10),
            Text(title.toUpperCase(),
                style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1.5)),
          ],
        ),
        const SizedBox(height: 12),
        // The Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.ink, width: 2.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.ink,
                  offset: Offset(5, 5)) // Signature Hard Shadow
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildLanguageControl() {
    final items = {'en': 'English', 'th': 'ไทย', 'es': 'Español', 'ja': '日本語'};
    final selectedValue = Get.locale?.languageCode ?? 'en';
    final keys = items.keys.toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: List.generate(keys.length, (index) {
          final key = keys[index];
          final isSelected = key == selectedValue;
          final isLast = index == keys.length - 1;

          return Expanded(
            child: InkWell(
              onTap: () => _changeLanguage(key),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.ink : Colors.transparent,
                  border: Border(
                    right: isLast
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.ink, width: 2),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    items[key]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSliderRow({
    required IconData icon,
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                      fontSize: 15)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.ink, width: 2),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: const [
                      BoxShadow(color: AppColors.ink, offset: Offset(2, 2))
                    ]),
                child: Text('${(value * 100).toInt()}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(icon, size: 28, color: AppColors.ink),
              const SizedBox(width: 16),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 10,
                    activeTrackColor: AppColors.ink,
                    inactiveTrackColor: AppColors.ink.withOpacity(0.1),
                    thumbColor: Colors.white,
                    overlayColor: AppColors.ink.withOpacity(0.1),
                    trackShape: const RoundedRectSliderTrackShape(),
                    thumbShape: _CustomThumbShape(),
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

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                  fontSize: 16)),
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: AppColors.ink,
            inactiveThumbColor: AppColors.ink,
            inactiveTrackColor: Colors.white,
            trackOutlineColor: MaterialStateProperty.all(AppColors.ink),
            trackOutlineWidth: MaterialStateProperty.all(2.0),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final Paint shadowPaint = Paint()..color = AppColors.ink;
    canvas.drawCircle(center + const Offset(2, 2), 12, shadowPaint);

    final Paint fillPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 12, fillPaint);

    final Paint strokePaint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 12, strokePaint);
  }
}
