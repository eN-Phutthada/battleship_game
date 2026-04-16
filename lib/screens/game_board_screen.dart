import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/game_models.dart';
import '../state/game_controller.dart';
import '../state/sound_controller.dart';
import '../utils/constants.dart';

import '../widgets/shared/animated_paper_bg.dart';
import '../widgets/board/hit_logs.dart';
import '../widgets/board/command_console.dart';
import '../widgets/board/ammo_status.dart';
import '../widgets/board/left_sidebar.dart';
import '../widgets/board/interactive_grid.dart';
import '../widgets/dialogs/abort_dialog.dart';
import '../widgets/dialogs/global_radar_dialog.dart';

class GameBoardScreen extends StatefulWidget {
  const GameBoardScreen({super.key});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformCtrl = TransformationController();
  late AnimationController _panController;
  Animation<Matrix4>? _panAnimation;
  BoxConstraints? _viewportConstraints;
  int? _lastPanShotTime;

  @override
  void initState() {
    super.initState();
    _panController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _panController.addListener(() {
      if (_panAnimation != null) {
        _transformCtrl.value = _panAnimation!.value;
      }
    });
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _panController.dispose();
    super.dispose();
  }

  void _playSound() {
    if (Get.isRegistered<SoundController>()) {
      Get.find<SoundController>().playClick();
    } else {
      Get.put(SoundController()).playClick();
    }
  }

  void _panToCell(int index, int cols, int rows, GameController game) {
    if (_viewportConstraints == null || !game.isAutoTrack) return;

    final double scale = _transformCtrl.value.getMaxScaleOnAxis();
    if (scale <= 1.05) return;

    final double wv = _viewportConstraints!.maxWidth;
    final double hv = _viewportConstraints!.maxHeight;
    final double ar = (cols + 1) / (rows + 1);

    // Calculate Grid dimensions
    final double wg = (wv / hv > ar) ? (hv * ar) : wv;
    final double hg = (wv / hv > ar) ? hv : (wv / ar);

    // Calculate Cell Center
    final double offsetX = (wv - wg) / 2;
    final double offsetY = (hv - hg) / 2;
    final double cw = wg / (cols + 1);
    final double ch = hg / (rows + 1);
    final int br = index ~/ cols;
    final int bc = index % cols;
    final double cx = offsetX + (bc + 1.5) * cw;
    final double cy = offsetY + (br + 1.5) * ch;

    // Check if currently visible
    final double curTx = _transformCtrl.value.getTranslation().x;
    final double curTy = _transformCtrl.value.getTranslation().y;
    final double screenX = curTx + (cx * scale);
    final double screenY = curTy + (cy * scale);

    const double padding = 60.0;
    final bool isVisible = screenX >= padding &&
        screenX <= wv - padding &&
        screenY >= padding &&
        screenY <= hv - padding;

    if (isVisible) return;

    // Calculate New Translation constraints
    double tx = (wv / 2) - (cx * scale);
    double ty = (hv / 2) - (cy * scale);
    final double minTx = wv - (wv * scale);
    final double minTy = hv - (hv * scale);

    tx = tx.clamp(minTx, 0.0);
    ty = ty.clamp(minTy, 0.0);

    final Matrix4 targetMatrix = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale);

    // Trigger Animation
    _panController.stop();
    int panDurationMs = (game.botSpeedMs * 0.7).toInt().clamp(0, 600);
    _panController.duration = Duration(milliseconds: panDurationMs);

    _panAnimation = Matrix4Tween(begin: _transformCtrl.value, end: targetMatrix)
        .animate(CurvedAnimation(
            parent: _panController, curve: Curves.easeInOutCubic));

    _panController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (await showAbortDialog()) Get.offAllNamed('/');
      },
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: AnimatedPaperBackground(
          child: SafeArea(
            child: GetBuilder<GameController>(
              builder: (game) {
                // State 1: Loading
                if (game.isDeploying || game.players.isEmpty) {
                  return _LoadingRadarScreen(game: game, playSound: _playSound);
                }

                // Data Prep
                final bool isMyTurn =
                    game.players[game.currentPlayerIndex].id == 0;
                final PlayerData viewTarget = game.players.firstWhere(
                  (p) => p.id == game.selectedTargetId,
                  orElse: () => game.players[1],
                );

                // Handle Pan Animation Dispatch
                if (game.activeShotAnimation != null) {
                  final int timestamp = game.activeShotAnimation!['timestamp'];
                  if (timestamp != _lastPanShotTime &&
                      game.activeShotAnimation!['targetId'] == viewTarget.id) {
                    _lastPanShotTime = timestamp;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _panToCell(game.activeShotAnimation!['index'],
                          game.columns, game.rows, game);
                    });
                  }
                }

                // State 2: Main Board
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _PaperPanel(
                              child: LeftSidebarWidget(
                                game: game,
                                playSound: _playSound,
                                onShowRadar: () => Get.dialog(GlobalRadarDialog(
                                    game: game, playSound: _playSound)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                _TargetHeader(viewTarget: viewTarget),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: InteractiveGridWidget(
                                    game: game,
                                    targetPlayer: viewTarget,
                                    isMyTurn: isMyTurn,
                                    transformCtrl: _transformCtrl,
                                    onConstraintsBuilt: (c) =>
                                        _viewportConstraints = c,
                                    playSound: _playSound,
                                  ),
                                ),
                                AmmoStatusWidget(game: game),
                                if (game.assistLevel == AssistLevel.realLife &&
                                    viewTarget.id != 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('hint_reallife'.tr,
                                        style: const TextStyle(
                                            color: AppColors.ink,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic)),
                                  )
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _PaperPanel(
                              child: Column(
                                children: [
                                  CommandConsoleWidget(
                                      game: game, playSound: _playSound),
                                  const HitLogsWidget(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (game.isTurnTransition)
                      _TurnTransitionOverlay(game: game, isMyTurn: isMyTurn),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PaperPanel extends StatelessWidget {
  final Widget child;
  const _PaperPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(4, 4))
        ],
      ),
      child: child,
    );
  }
}

class _TargetHeader extends StatelessWidget {
  final PlayerData viewTarget;
  const _TargetHeader({required this.viewTarget});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.ink, width: 2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, offset: Offset(2, 2))
          ]),
      child: Text(
        viewTarget.id == 0
            ? 'defending'.tr
            : 'targeting'.trParams({'name': viewTarget.name}),
        style: TextStyle(
            color: viewTarget.id == 0 ? Colors.green[800] : AppColors.redPen,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TurnTransitionOverlay extends StatelessWidget {
  final GameController game;
  final bool isMyTurn;

  const _TurnTransitionOverlay({required this.game, required this.isMyTurn});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.5, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.elasticOut,
          builder: (context, val, child) {
            return Transform.scale(
              scale: val,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: const BoxDecoration(
                    color: AppColors.paper,
                    border: Border.symmetric(
                        horizontal: BorderSide(color: AppColors.ink, width: 6)),
                    boxShadow: [
                      BoxShadow(color: Colors.black54, blurRadius: 10)
                    ]),
                child: Text(game.turnTransitionMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isMyTurn ? Colors.green[800] : AppColors.redPen,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoadingRadarScreen extends StatefulWidget {
  final GameController game;
  final VoidCallback playSound;

  const _LoadingRadarScreen({required this.game, required this.playSound});

  @override
  State<_LoadingRadarScreen> createState() => _LoadingRadarScreenState();
}

class _LoadingRadarScreenState extends State<_LoadingRadarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  int _secretTapCount = 0;
  DateTime? _lastSecretTap;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  void _handleSecretTap() {
    final DateTime now = DateTime.now();
    if (_lastSecretTap == null ||
        now.difference(_lastSecretTap!) > const Duration(seconds: 2)) {
      _secretTapCount = 1;
    } else {
      _secretTapCount++;
    }
    _lastSecretTap = now;

    if (_secretTapCount >= 5) {
      _secretTapCount = 0;
      widget.playSound();
      widget.game.toggleDevMode();
      HapticFeedback.heavyImpact();
      Get.snackbar(
        'DEV MODE',
        widget.game.isDevMode
            ? 'Cheat Activated: All ships revealed!'
            : 'Cheat Deactivated',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87,
        colorText: Colors.greenAccent,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _handleSecretTap,
            child: AnimatedBuilder(
              animation: _radarController,
              builder: (context, child) {
                final val = _radarController.value;
                return Transform.scale(
                  scale: 0.5 + (val * 1.5),
                  child: Opacity(
                      opacity: 1.0 - val,
                      child: const Icon(Icons.radar,
                          color: AppColors.ink, size: 50)),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.ink, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, offset: Offset(4, 4))
                ]),
            child: Text('simulating'.tr,
                style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2)),
          ),
        ],
      ),
    );
  }
}
