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
    with TickerProviderStateMixin {
  late AnimationController _radarController;
  final TransformationController _transformCtrl = TransformationController();
  late AnimationController _panController;
  Animation<Matrix4>? _panAnimation;
  BoxConstraints? _viewportConstraints;
  int? _lastPanShotTime;

  int _secretTapCount = 0;
  DateTime? _lastSecretTap;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

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
    _radarController.dispose();
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

  void _handleSecretTap(GameController game) {
    DateTime now = DateTime.now();
    if (_lastSecretTap == null ||
        now.difference(_lastSecretTap!) > const Duration(seconds: 2)) {
      _secretTapCount = 1;
    } else {
      _secretTapCount++;
    }
    _lastSecretTap = now;

    if (_secretTapCount >= 5) {
      _secretTapCount = 0;
      _playSound();
      game.toggleDevMode();
      HapticFeedback.heavyImpact();
      Get.snackbar(
        'DEV MODE',
        game.isDevMode
            ? 'Cheat Activated: All ships revealed!'
            : 'Cheat Deactivated',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87,
        colorText: Colors.greenAccent,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _panToCell(int index, int cols, int rows, GameController game) {
    if (_viewportConstraints == null || !game.isAutoTrack) return;

    double scale = _transformCtrl.value.getMaxScaleOnAxis();
    if (scale <= 1.05) return;

    double wv = _viewportConstraints!.maxWidth;
    double hv = _viewportConstraints!.maxHeight;
    double ar = (cols + 1) / (rows + 1);
    double wg, hg;

    if (wv / hv > ar) {
      hg = hv;
      wg = hg * ar;
    } else {
      wg = wv;
      hg = wg / ar;
    }

    double offsetX = (wv - wg) / 2;
    double offsetY = (hv - hg) / 2;
    double cw = wg / (cols + 1);
    double ch = hg / (rows + 1);
    int br = index ~/ cols;
    int bc = index % cols;
    double cx = offsetX + (bc + 1.5) * cw;
    double cy = offsetY + (br + 1.5) * ch;

    double curTx = _transformCtrl.value.getTranslation().x;
    double curTy = _transformCtrl.value.getTranslation().y;
    double screenX = curTx + (cx * scale);
    double screenY = curTy + (cy * scale);

    double padding = 60.0;
    bool isVisible = screenX >= padding &&
        screenX <= wv - padding &&
        screenY >= padding &&
        screenY <= hv - padding;

    if (isVisible) return;

    double tx = (wv / 2) - (cx * scale);
    double ty = (hv / 2) - (cy * scale);
    double minTx = wv - (wv * scale);
    double minTy = hv - (hv * scale);

    tx = tx.clamp(minTx, 0.0);
    ty = ty.clamp(minTy, 0.0);

    Matrix4 targetMatrix = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale);

    _panController.stop();
    int panDurationMs = (game.botSpeedMs * 0.7).toInt();
    if (panDurationMs > 600) panDurationMs = 600;
    _panController.duration = Duration(milliseconds: panDurationMs);

    _panAnimation = Matrix4Tween(begin: _transformCtrl.value, end: targetMatrix)
        .animate(CurvedAnimation(
            parent: _panController, curve: Curves.easeInOutCubic));

    _panController.forward(from: 0.0);
  }

  Widget _buildPaperPanel({required Widget child}) {
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

  Widget _buildTargetHeader(PlayerData viewTarget) {
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

  Widget _buildTurnTransitionOverlay(GameController game, bool isMyTurn) {
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

  Widget _buildLoadingScreen(GameController game) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _handleSecretTap(game),
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
                if (game.isDeploying || game.players.isEmpty) {
                  return _buildLoadingScreen(game);
                }

                bool isMyTurn = game.players[game.currentPlayerIndex].id == 0;
                PlayerData viewTarget = game.players.firstWhere(
                  (p) => p.id == game.selectedTargetId,
                  orElse: () => game.players[1],
                );

                if (game.activeShotAnimation != null) {
                  int timestamp = game.activeShotAnimation!['timestamp'];
                  if (timestamp != _lastPanShotTime &&
                      game.activeShotAnimation!['targetId'] == viewTarget.id) {
                    _lastPanShotTime = timestamp;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _panToCell(game.activeShotAnimation!['index'],
                          game.columns, game.rows, game);
                    });
                  }
                }

                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildPaperPanel(
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
                                _buildTargetHeader(viewTarget),
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
                            child: _buildPaperPanel(
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
                      _buildTurnTransitionOverlay(game, isMyTurn),
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
