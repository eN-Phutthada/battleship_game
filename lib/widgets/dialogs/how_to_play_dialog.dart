import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../state/sound_controller.dart';

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

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

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 600),
        padding: const EdgeInsets.all(20),
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
            Expanded(
              child: isMobile
                  ? SingleChildScrollView(
                      child: _buildContent()) // แนวตั้งสำหรับมือถือ
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                                child: _buildLeftColumn())),
                        const VerticalDivider(
                            color: AppColors.ink, width: 30, thickness: 1.5),
                        Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                                child: _buildRightColumn())),
                      ],
                    ), // แบ่งสองคอลัมน์สำหรับ Tablet/Desktop
            ),
            const Divider(color: AppColors.ink, thickness: 1.5, height: 24),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.thumb_up, color: Colors.white, size: 16),
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
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftColumn(),
        const SizedBox(height: 20),
        const Divider(color: Colors.black26),
        const SizedBox(height: 20),
        _buildRightColumn(),
      ],
    );
  }

  Widget _buildLeftColumn() {
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

  Widget _buildRightColumn() {
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
}
