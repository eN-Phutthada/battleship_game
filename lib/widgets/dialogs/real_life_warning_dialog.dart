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
      // เพิ่ม insetPadding เพื่อป้องกันไม่ให้ Dialog ขยายเต็มจอบนหน้าจอมือถือขนาดเล็ก
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        // ปรับขนาด maxHeight เล็กน้อยเผื่อเนื้อหาที่ยาวขึ้น
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 450),
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
              // 1. เพิ่ม Scrollbar เพื่อให้ฝั่ง Web/Desktop ใช้เมาส์ลากได้ชัดเจน
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  // 2. เพิ่ม BouncingScrollPhysics ให้การเลื่อนดูนุ่มนวลและเป็นธรรมชาติ
                  physics: const BouncingScrollPhysics(),
                  // 3. เพิ่ม padding แนวนอนเล็กน้อยเพื่อไม่ให้ตัวหนังสือชิด Scrollbar เกินไป
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('rl_warning_desc'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 14, // ปรับขนาด font ขึ้นเล็กน้อยให้อ่านง่าย
                          fontWeight: FontWeight.bold,
                          height: 1.5)),
                ),
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
                        // 4. เพิ่ม padding แนวนอนให้ปุ่มสูงขึ้น คลิกด้วยเมาส์หรือนิ้วได้ง่ายกว่าเดิม
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                        // เพิ่ม padding ให้ปุ่มสูงเท่ากัน
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
