import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../state/sound_controller.dart';

class RealLifeWarningDialog extends StatelessWidget {
  final VoidCallback onProceed;

  const RealLifeWarningDialog({super.key, required this.onProceed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 400),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFBF7), // AppColors.paper (or variant)
          border: Border.all(color: AppColors.redPen, width: 4),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black26, offset: Offset(8, 8))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.visibility_off, color: AppColors.redPen, size: 48),
            const SizedBox(height: 12),
            Text('rl_warning_title'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.redPen,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.2)),
            const Divider(color: AppColors.redPen, thickness: 2, height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text('rl_warning_desc'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.5)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.find<SoundController>().playClick();
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.ink, width: 2)),
                    child: Text('cancel_btn'.tr,
                        style: const TextStyle(
                            color: AppColors.ink, fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.find<SoundController>().playClick();
                      Get.back();
                      onProceed();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redPen),
                    child: Text('accept_btn'.tr,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
