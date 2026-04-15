import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../state/game_controller.dart';
import '../state/multiplayer_controller.dart';
import '../state/sound_controller.dart';
import '../utils/constants.dart';
import '../widgets/shared/animated_paper_bg.dart';
import '../widgets/dialogs/how_to_play_dialog.dart';
import '../widgets/dialogs/multiplayer_dialog.dart';
import '../widgets/dialogs/real_life_warning_dialog.dart';
import '../widgets/dialogs/settings_dialog.dart';

enum BoardSize { standard, large, huge }

extension BoardSizeExt on BoardSize {
  int get cols =>
      this == BoardSize.standard ? 8 : (this == BoardSize.large ? 10 : 12);
  int get rows =>
      this == BoardSize.standard ? 6 : (this == BoardSize.large ? 8 : 10);
  String get label => this == BoardSize.standard
      ? '8x6'
      : (this == BoardSize.large ? '10x8' : '12x10');
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  int enemyCount = 1;
  BotDifficulty botDifficulty = BotDifficulty.normal;
  AssistLevel assistLevel = AssistLevel.standard;
  BoardSize boardSize = BoardSize.standard;

  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  late AnimationController _animController;

  final MultiplayerController mpCtrl = Get.put(MultiplayerController());
  late SoundController _sound;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _nameController.text = "Commander${Random().nextInt(1000)}";
    _sound = Get.put(SoundController());
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  bool _validateName() {
    if (_nameController.text.trim().isEmpty) {
      _sound.vibrateHeavy();
      _sound.playError();
      Get.snackbar(
        'attention'.tr,
        'err_empty_name'.tr,
        backgroundColor: const Color(0xFFFDFBF7),
        colorText: AppColors.redPen,
        borderColor: AppColors.redPen,
        borderWidth: 2,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.warning_amber_rounded,
            color: AppColors.redPen, size: 28),
        snackPosition: SnackPosition.TOP,
      );
      _nameFocusNode.requestFocus();
      return false;
    }
    return true;
  }

  void _handleStartLocalCampaign() {
    if (!_validateName()) return;

    proceedToGame() {
      _sound.vibrateHeavy();
      _sound.playClick();
      final gameCtrl = Get.find<GameController>();
      gameCtrl.botDifficulty = botDifficulty;
      gameCtrl.assistLevel = assistLevel;
      Get.toNamed('/placement', arguments: {
        'enemyCount': enemyCount,
        'playerName': _nameController.text.trim().toUpperCase(),
        'columns': boardSize.cols,
        'rows': boardSize.rows
      });
    }

    if (assistLevel == AssistLevel.realLife) {
      _sound.vibrateHeavy();
      _sound.playError();
      Get.dialog(RealLifeWarningDialog(onProceed: proceedToGame),
          barrierDismissible: false);
    } else {
      proceedToGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: AnimatedPaperBackground(
        child: SafeArea(
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 800;

                  Widget brandingSection = _buildBrandingSection(isMobile);
                  Widget formSection = _buildFormSection();

                  if (isMobile) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          brandingSection,
                          const SizedBox(height: 30),
                          const Divider(color: AppColors.ink, thickness: 1),
                          const SizedBox(height: 30),
                          formSection,
                        ],
                      ),
                    );
                  }

                  return Row(
                    children: [
                      Expanded(flex: 4, child: brandingSection),
                      Container(
                        width: 2,
                        height: double.infinity,
                        color: AppColors.ink.withOpacity(0.2),
                        margin: const EdgeInsets.symmetric(vertical: 40),
                      ),
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                            child: formSection,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              Positioned(
                bottom: 12,
                left: 20,
                child: Text(
                  "v1.0.0 - Commander Edition",
                  style: TextStyle(
                      color: AppColors.ink.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection(bool isMobile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final value = _animController.value * 2 * pi;
            return Transform.translate(
              offset: Offset(0, 8 * sin(value)),
              child: Transform.rotate(
                angle: -0.1 + (0.05 * cos(value)),
                child: Icon(Icons.directions_boat_outlined,
                    size: isMobile ? 80 : 100, color: AppColors.ink),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.elasticOut,
          builder: (context, val, child) => Transform.scale(
            scale: val,
            child: Text(
              'PAPER\nBATTLESHIP',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 32 : 38,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
                letterSpacing: 4,
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.wavy,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHeaderActions(),
        const SizedBox(height: 24),
        _buildCommanderInput(),
        const SizedBox(height: 24),
        _buildLocalCampaignCard(),
        const SizedBox(height: 16),
        _buildNetworkCard(),
      ],
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('mission_briefing'.tr,
            style: const TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2)),
        Row(
          children: [
            PaperActionButton(
                icon: Icons.settings,
                onTap: () => Get.dialog(const SettingsDialog())),
            const SizedBox(width: 8),
            PaperActionButton(
                icon: Icons.question_mark,
                onTap: () => Get.dialog(const HowToPlayDialog())),
          ],
        ),
      ],
    );
  }

  Widget _buildCommanderInput() {
    return PaperContainer(
      child: TextField(
        controller: _nameController,
        focusNode: _nameFocusNode,
        textAlign: TextAlign.center,
        maxLength: 12,
        style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 2),
        decoration: InputDecoration(
          counterText: "",
          labelText: 'commander_name'.tr,
          prefixIcon: const Icon(Icons.badge, color: AppColors.ink),
          labelStyle: TextStyle(
              color: AppColors.ink.withOpacity(0.6),
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLocalCampaignCard() {
    return PaperContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.smart_toy, color: AppColors.ink, size: 22),
              const SizedBox(width: 8),
              Text('local_campaign'.tr,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2)),
            ],
          ),
          const Divider(color: AppColors.ink, height: 24, thickness: 1.5),
          _buildConfigRow(
              'difficulty'.tr,
              CustomSegmentedControl<BotDifficulty>(
                selectedValue: botDifficulty,
                items: {
                  BotDifficulty.easy: 'diff_easy'.tr,
                  BotDifficulty.normal: 'diff_normal'.tr,
                  BotDifficulty.hard: 'diff_hard'.tr,
                },
                onChanged: (val) => setState(() => botDifficulty = val),
              )),
          _buildConfigRow(
              'assist_level'.tr,
              CustomSegmentedControl<AssistLevel>(
                selectedValue: assistLevel,
                activeColor: AppColors.redPen,
                items: {
                  AssistLevel.casual: 'ast_casual'.tr,
                  AssistLevel.standard: 'ast_standard'.tr,
                  AssistLevel.hardcore: 'ast_hardcore'.tr,
                  AssistLevel.realLife: 'ast_reallife'.tr,
                },
                onChanged: (val) => setState(() => assistLevel = val),
              )),
          _buildConfigRow(
              'grid_size'.tr,
              CustomSegmentedControl<BoardSize>(
                selectedValue: boardSize,
                activeColor: Colors.green[800]!,
                items: {
                  BoardSize.standard: BoardSize.standard.label,
                  BoardSize.large: BoardSize.large.label,
                  BoardSize.huge: BoardSize.huge.label,
                },
                onChanged: (val) => setState(() => boardSize = val),
              )),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildEnemyCounter(),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handleStartLocalCampaign,
                  icon: const Icon(Icons.rocket_launch, color: AppColors.paper),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('engage_bots'.tr,
                        style: const TextStyle(
                            color: AppColors.paper,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow(String title, Widget control) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 12)),
        const SizedBox(height: 6),
        control,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEnemyCounter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('enemies'.tr,
            style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.ink),
              borderRadius: BorderRadius.circular(6)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: const Icon(Icons.remove, color: AppColors.ink, size: 18),
                onPressed: () => setState(() {
                  if (enemyCount > 1) {
                    _sound.playClick();
                    enemyCount--;
                  }
                }),
              ),
              Text("$enemyCount",
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: const Icon(Icons.add, color: AppColors.ink, size: 18),
                onPressed: () => setState(() {
                  if (enemyCount < 7) {
                    _sound.playClick();
                    enemyCount++;
                  }
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkCard() {
    return PaperContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_tethering, color: AppColors.ink, size: 20),
              const SizedBox(width: 8),
              Text('network_battle'.tr,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 4),
          Text('lan_desc'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.ink.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              if (_validateName()) {
                Get.dialog(
                    MultiplayerDialog(
                        playerName: _nameController.text.trim().toUpperCase()),
                    barrierDismissible: false);
              }
            },
            icon: const Icon(Icons.cell_tower, color: AppColors.ink),
            label: Text('host_join'.tr,
                style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w900)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.ink, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }
}

class PaperContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const PaperContainer(
      {super.key, required this.child, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(4, 4))
        ],
      ),
      child: child,
    );
  }
}

class PaperActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const PaperActionButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.find<SoundController>().playClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
                color: AppColors.ink.withOpacity(0.2),
                offset: const Offset(2, 2))
          ],
        ),
        child: Icon(icon, color: AppColors.ink, size: 20),
      ),
    );
  }
}

class CustomSegmentedControl<T> extends StatelessWidget {
  final Map<T, String> items;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final Color activeColor;

  const CustomSegmentedControl({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.activeColor = AppColors.ink,
  });

  @override
  Widget build(BuildContext context) {
    final keys = items.keys.toList();
    return Row(
      children: List.generate(keys.length, (index) {
        final key = keys[index];
        final isSelected = key == selectedValue;
        final isFirst = index == 0;
        final isLast = index == keys.length - 1;

        return Expanded(
          child: InkWell(
            onTap: () {
              Get.find<SoundController>().playClick();
              onChanged(key);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(isFirst ? 6 : 0),
                  right: Radius.circular(isLast ? 6 : 0),
                ),
                border: Border(
                  top: BorderSide(color: activeColor, width: 1),
                  bottom: BorderSide(color: activeColor, width: 1),
                  left: BorderSide(color: activeColor, width: 1),
                  right: isLast
                      ? BorderSide(color: activeColor, width: 1)
                      : BorderSide.none,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    items[key]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : activeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
