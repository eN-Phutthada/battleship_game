import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../state/sound_controller.dart';

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 650;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.paper,
          border: Border.all(color: AppColors.ink, width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black26, offset: Offset(8, 8))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, color: AppColors.ink, size: 32),
                    const SizedBox(width: 12),
                    Text('how_to_play'.tr,
                        style: const TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            letterSpacing: 1.5)),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, color: AppColors.ink, size: 32),
                  onPressed: () {
                    Get.find<SoundController>().playClick();
                    Get.back();
                  },
                ),
              ],
            ),
            const Divider(color: AppColors.ink, thickness: 2, height: 24),

            // --- CONTENT SCROLL AREA ---
            Expanded(
              child: isMobile ? _buildMobileLayout() : _buildTabletLayout(),
            ),

            const Divider(color: AppColors.ink, thickness: 1.5, height: 24),

            // --- FOOTER & CREDITS (✨ ปรับปรุงใหม่ให้โดดเด่นขึ้น ✨) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          AppColors.ink.withOpacity(0.05), // พื้นหลังทึบอ่อนๆ
                      border: Border.all(
                          color: AppColors.ink.withOpacity(0.5), width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.smart_display_outlined,
                            color: AppColors.ink, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('credits'.tr,
                                  style: const TextStyle(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 1.2)),
                              const SizedBox(height: 4),
                              Text('credit_desc'.tr,
                                  style: const TextStyle(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height:
                      45, // ปรับให้สูงขึ้นนิดหน่อยเพื่อให้บาลานซ์กับกล่อง Credit
                  width: 150,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.thumb_up,
                        color: Colors.white, size: 18),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6))),
                    onPressed: () {
                      Get.find<SoundController>().playClick();
                      Get.back();
                    },
                    label: Text('roger_that'.tr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            fontSize: 14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeftContent(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Colors.black26, thickness: 1),
          ),
          _buildRightContent(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _buildLeftContent(),
            ),
          ),
        ),
        const VerticalDivider(color: AppColors.ink, width: 30, thickness: 1.5),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _buildRightContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHelpSectionTitle(Icons.map, 'deployment_phase'.tr),
        const SizedBox(height: 8),
        _buildStep(Icons.landscape, 'help_step_1'.tr),
        _buildStep(Icons.fort, 'help_step_2'.tr),
        _buildStep(Icons.directions_boat, 'help_step_3'.tr),
        const SizedBox(height: 20),
        _buildHelpSectionTitle(Icons.gavel, 'combat_rules'.tr),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              border:
                  Border.all(color: Colors.red.withOpacity(0.5), width: 1.5),
              borderRadius: BorderRadius.circular(6)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRuleText('rule_1'.tr),
              const SizedBox(height: 8),
              _buildRuleText('rule_2'.tr),
              const SizedBox(height: 8),
              _buildRuleText('rule_3'.tr),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHelpSectionTitle(Icons.smart_toy, 'help_diff_title'.tr),
        const SizedBox(height: 8),
        _buildDescItem('help_diff_easy'.tr),
        const Divider(color: Colors.black12, height: 16),
        _buildDescItem('help_diff_normal'.tr),
        const Divider(color: Colors.black12, height: 16),
        _buildDescItem('help_diff_hard'.tr),
        const SizedBox(height: 20),
        _buildHelpSectionTitle(Icons.handshake, 'help_assist_title'.tr),
        const SizedBox(height: 8),
        _buildDescItem('help_ast_casual'.tr),
        const Divider(color: Colors.black12, height: 16),
        _buildDescItem('help_ast_standard'.tr),
        const Divider(color: Colors.black12, height: 16),
        _buildDescItem('help_ast_hardcore'.tr),
        const Divider(color: Colors.black12, height: 16),
        _buildDescItem('help_ast_reallife'.tr),
      ],
    );
  }

  Widget _buildHelpSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.ink, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                decoration: TextDecoration.underline)),
      ],
    );
  }

  Widget _buildStep(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.ink, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                      fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildRuleText(String text) {
    return Text(text,
        style: TextStyle(
            color: Colors.red[800], fontSize: 12, fontWeight: FontWeight.w900));
  }

  Widget _buildDescItem(String text) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            height: 1.3));
  }
}
