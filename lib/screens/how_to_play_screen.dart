import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../state/sound_controller.dart';
import '../widgets/shared/animated_paper_bg.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: AnimatedPaperBackground(
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER (Aligned with SettingsScreen) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    _buildBackButton(),
                    const SizedBox(width: 16),
                    const Icon(Icons.menu_book, color: AppColors.ink, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('how_to_play'.tr,
                          style: const TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
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
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: isMobile
                          ? _buildMobileLayout()
                          : _buildTabletLayout(),
                    ),
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

  Widget _buildMobileLayout() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        _buildDeploymentCard(),
        const SizedBox(height: 32),
        _buildCombatRulesCard(),
        const SizedBox(height: 32),
        _buildDifficultyCard(),
        const SizedBox(height: 32),
        _buildAssistCard(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDeploymentCard(),
                const SizedBox(height: 32),
                _buildCombatRulesCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDifficultyCard(),
                const SizedBox(height: 32),
                _buildAssistCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION CARDS (UI COMPONENTS)
  // ==========================================

  Widget _buildDeploymentCard() {
    return _buildPaperCard(
      title: 'deployment_phase'.tr,
      icon: Icons.map,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStep(Icons.landscape, 'help_step_1'.tr),
          _buildStep(Icons.fort, 'help_step_2'.tr),
          _buildStep(Icons.directions_boat, 'help_step_3'.tr, isLast: true),
        ],
      ),
    );
  }

  Widget _buildCombatRulesCard() {
    return _buildPaperCard(
      title: 'combat_rules'.tr,
      icon: Icons.gavel,
      accentColor: Colors.red[800],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRuleText('rule_1'.tr),
          _buildRuleText('rule_2'.tr),
          _buildRuleText('rule_3'.tr, isLast: true),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard() {
    return _buildPaperCard(
      title: 'help_diff_title'.tr,
      icon: Icons.smart_toy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDescItem('help_diff_easy'.tr),
          _buildDescItem('help_diff_normal'.tr),
          _buildDescItem('help_diff_hard'.tr, isLast: true),
        ],
      ),
    );
  }

  Widget _buildAssistCard() {
    return _buildPaperCard(
      title: 'help_assist_title'.tr,
      icon: Icons.handshake,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDescItem('help_ast_casual'.tr),
          _buildDescItem('help_ast_standard'.tr),
          _buildDescItem('help_ast_hardcore'.tr),
          _buildDescItem('help_ast_reallife'.tr, isLast: true),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  /// การ์ดสไตล์กระดาษที่มี Title ด้านนอกแบบเดียวกับ SettingsScreen
  Widget _buildPaperCard({
    required String title,
    required IconData icon,
    required Widget child,
    Color? accentColor,
  }) {
    final color = accentColor ?? AppColors.ink;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Text(title.toUpperCase(),
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1.5)),
          ],
        ),
        const SizedBox(height: 12),
        // The Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: color, width: 2.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: color,
                  offset: const Offset(5, 5)) // Signature Hard Shadow
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildStep(IconData icon, String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.ink.withOpacity(0.08),
              border:
                  Border.all(color: AppColors.ink.withOpacity(0.3), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.ink, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleText(String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red[800]!.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.priority_high, color: Colors.red[800], size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(text,
                  style: TextStyle(
                      color: Colors.red[900],
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescItem(String text, {bool isLast = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.ink.withOpacity(0.03),
        border: Border.all(color: AppColors.ink.withOpacity(0.15), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.5)),
    );
  }
}
