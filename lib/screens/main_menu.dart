import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../state/game_controller.dart';
import '../state/multiplayer_controller.dart';
import '../state/sound_controller.dart';
import '../screens/how_to_play_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/constants.dart';
import '../widgets/shared/animated_paper_bg.dart';
import '../widgets/dialogs/multiplayer_dialog.dart';
import '../widgets/dialogs/real_life_warning_dialog.dart';

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

  int _logoTapCount = 0;
  IconData _currentVehicleIcon = Icons.directions_boat_outlined;
  OverlayEntry? _activeEasterEgg;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _nameController.text = "Commander${Random().nextInt(1000)}";
    _sound = Get.put(SoundController());

    if (Get.isRegistered<GameController>()) {
      Get.find<GameController>().vehicleTheme = VehicleTheme.boat;
    }
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
                          horizontal: 24, vertical: 24),
                      child: Column(
                        children: [
                          brandingSection,
                          const SizedBox(height: 32),
                          const Divider(color: AppColors.ink, thickness: 2),
                          const SizedBox(height: 32),
                          formSection,
                        ],
                      ),
                    );
                  }

                  return Row(
                    children: [
                      Expanded(flex: 4, child: brandingSection),
                      Container(
                        width: 2.5,
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
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: formSection,
                            ),
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
        GestureDetector(
          onTap: _handleLogoTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final value = _animController.value * 2 * pi;
              return Transform.translate(
                offset: Offset(0, 8 * sin(value)),
                child: Transform.rotate(
                  angle: -0.1 + (0.05 * cos(value)),
                  child: Icon(_currentVehicleIcon,
                      size: isMobile ? 80 : 100, color: AppColors.ink),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.elasticOut,
          builder: (context, val, child) => Transform.scale(
            scale: val,
            child: Text(
              'game_title'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 36 : 42,
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
        const SizedBox(height: 28),
        _buildCommanderInput(),
        const SizedBox(height: 28),
        _buildLocalCampaignCard(),
        const SizedBox(height: 24),
        _buildNetworkCard(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text('mission_briefing'.tr,
              style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5)),
        ),
        Row(
          children: [
            PaperActionButton(
                icon: Icons.info_outline, onTap: _showCreditsDialog),
            const SizedBox(width: 10),
            PaperActionButton(
                icon: Icons.settings,
                onTap: () => Get.to(() => const SettingsScreen())),
            const SizedBox(width: 10),
            PaperActionButton(
                icon: Icons.question_mark,
                onTap: () => Get.to(() => const HowToPlayScreen())),
          ],
        ),
      ],
    );
  }

  void _showCreditsDialog() {
    _sound.playClick();
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: PaperContainer(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.smart_display_outlined,
                        color: AppColors.ink, size: 32),
                    const SizedBox(width: 12),
                    Text('credits'.tr,
                        style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5)),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.ink, thickness: 2.5),
                const SizedBox(height: 16),
                Text('credit_desc'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.6)),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: () {
                      _sound.playClick();
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
          ),
        ),
      ),
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
            fontSize: 20,
            letterSpacing: 2),
        decoration: InputDecoration(
          counterText: "",
          labelText: 'commander_name'.tr,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(Icons.badge, color: AppColors.ink, size: 28),
          ),
          labelStyle: TextStyle(
              color: AppColors.ink.withOpacity(0.7),
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _buildLocalCampaignCard() {
    return PaperContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.smart_toy, color: AppColors.ink, size: 24),
              const SizedBox(width: 12),
              Text('local_campaign'.tr,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.ink, thickness: 2.5),
          const SizedBox(height: 16),
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
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildEnemyCounter(),
              const SizedBox(width: 20),
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
                            letterSpacing: 1.5)),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.ink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
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
        Text(title.toUpperCase(),
            style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.2)),
        const SizedBox(height: 8),
        control,
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEnemyCounter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('enemies'.tr.toUpperCase(),
            style: const TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.ink, width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: AppColors.ink, offset: Offset(2, 2))
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(Icons.remove, color: AppColors.ink, size: 20),
                onPressed: () => setState(() {
                  if (enemyCount > 1) {
                    _sound.playClick();
                    enemyCount--;
                  }
                }),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text("$enemyCount",
                    style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(Icons.add, color: AppColors.ink, size: 20),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_tethering, color: AppColors.ink, size: 24),
              const SizedBox(width: 12),
              Text('network_battle'.tr,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 8),
          Text('lan_desc'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.ink.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
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
                    fontSize: 16,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w900)),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.ink, width: 2.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogoTap() {
    setState(() {
      _logoTapCount++;
      final gameCtrl = Get.find<GameController>();

      if (_logoTapCount == 7) {
        _currentVehicleIcon = Icons.anchor;
        gameCtrl.vehicleTheme = VehicleTheme.submarine;
        _triggerEasterEgg('ee_sub'.tr);
      } else if (_logoTapCount == 14) {
        _currentVehicleIcon = Icons.rocket_launch_outlined;
        gameCtrl.vehicleTheme = VehicleTheme.space;
        _triggerEasterEgg('ee_rocket'.tr);
      } else if (_logoTapCount == 21) {
        _currentVehicleIcon = Icons.directions_boat_outlined;
        gameCtrl.vehicleTheme = VehicleTheme.boat;
        _logoTapCount = 0;
        _triggerEasterEgg('ee_boat'.tr);
      } else {
        _sound.playClick();
      }
    });
  }

  void _triggerEasterEgg(String message) {
    _sound.vibrateHeavy();

    if (_activeEasterEgg != null) {
      _activeEasterEgg?.remove();
      _activeEasterEgg = null;
    }

    final overlayState = Overlay.of(context);
    _activeEasterEgg = OverlayEntry(
      builder: (context) => EasterEggToast(
        message: message,
        icon: _currentVehicleIcon,
        onClose: () {
          if (mounted && _activeEasterEgg != null) {
            _activeEasterEgg?.remove();
            _activeEasterEgg = null;
          }
        },
      ),
    );

    overlayState.insert(_activeEasterEgg!);
  }
}

// ==========================================
// SHARED UI COMPONENTS (Updated to match SettingsScreen)
// ==========================================

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
        border: Border.all(color: AppColors.ink, width: 2.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: AppColors.ink, offset: Offset(5, 5))
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
        child: Icon(icon, color: AppColors.ink, size: 24),
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(isFirst ? 6 : 0),
                    right: Radius.circular(isLast ? 6 : 0),
                  ),
                  border: Border(
                    right: isLast
                        ? BorderSide.none
                        : const BorderSide(color: AppColors.ink, width: 2),
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
                        color: isSelected ? Colors.white : AppColors.ink,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
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
}

class EasterEggToast extends StatefulWidget {
  final String message;
  final IconData icon;
  final VoidCallback onClose;

  const EasterEggToast({
    super.key,
    required this.message,
    required this.icon,
    required this.onClose,
  });

  @override
  State<EasterEggToast> createState() => _EasterEggToastState();
}

class _EasterEggToastState extends State<EasterEggToast>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);

    _slideController.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        await _slideController.reverse();
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -2), end: Offset.zero)
              .animate(CurvedAnimation(
                  parent: _slideController, curve: Curves.elasticOut)),
          child: PaperContainer(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1.15).animate(
                      CurvedAnimation(
                          parent: _pulseController, curve: Curves.easeInOut)),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.ink,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 2),
                            blurRadius: 4)
                      ],
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'roger_that'.tr,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.message,
                        style: TextStyle(
                          color: AppColors.ink.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
