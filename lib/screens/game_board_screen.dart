import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../state/game_controller.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';
import '../widgets/shared_widgets.dart';

class GameBoardScreen extends StatefulWidget {
  const GameBoardScreen({super.key});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

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

  Widget _buildPaperPanel({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(4, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildRadarThumb(PlayerData player, GameController game) {
    bool isMe = player.id == 0;
    bool isDead = player.isDefeated;
    return GestureDetector(
      onTap: () {
        if (!isMe && !isDead) {
          game.selectTarget(player.id);
          Get.back();
        } else if (isMe) {
          game.selectTarget(0);
          Get.back();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isDead ? Colors.grey : AppColors.ink,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black12, offset: Offset(2, 2)),
          ],
        ),
        child: Column(
          children: [
            Text(
              isDead
                  ? "${player.name} ☠️"
                  : (isMe ? 'my_fleet'.tr : player.name),
              style: TextStyle(
                color: isDead
                    ? Colors.grey
                    : (isMe ? Colors.green[800] : AppColors.ink),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDead ? Colors.grey : AppColors.ink,
                    width: 1.5,
                  ),
                  color: isDead
                      ? Colors.grey.withOpacity(0.2)
                      : Colors.blue[50]!.withOpacity(0.3),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    crossAxisSpacing: 0.5,
                    mainAxisSpacing: 0.5,
                  ),
                  itemCount: 48,
                  itemBuilder: (ctx, i) {
                    Cell cell = player.board[i]!;
                    Color c = Colors.transparent;
                    if (cell.isRevealed &&
                        (cell.entity == Entity.ship ||
                            cell.entity == Entity.turret)) {
                      c = AppColors.redPen;
                    } else if (isMe &&
                        cell.entity != Entity.none &&
                        !cell.isRevealed) {
                      c = AppColors.ink.withOpacity(0.5);
                    }
                    return Container(color: c);
                  },
                ),
              ),
            ),
          ],
        ),
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
                  return _buildLoadingScreen();
                }

                bool isMyTurn = game.players[game.currentPlayerIndex].id == 0;
                PlayerData viewTarget = game.players.firstWhere(
                  (p) => p.id == game.selectedTargetId,
                  orElse: () => game.players[1],
                );

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
                              child: _buildLeftSidebar(context, game),
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
                                  child: _buildAnimatedPaperGrid(
                                    game,
                                    viewTarget,
                                    isMyTurn,
                                  ),
                                ),
                                _buildAmmoStatus(game),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _buildPaperPanel(
                              child: Column(
                                children: [
                                  _buildCommandConsole(game),
                                  _buildHitLogs(game),
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

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _radarController,
            builder: (context, child) {
              final val = _radarController.value;
              return Transform.scale(
                scale: 0.5 + (val * 1.5),
                child: Opacity(
                  opacity: 1.0 - val,
                  child: const Icon(
                    Icons.radar,
                    color: AppColors.ink,
                    size: 50,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.ink, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black12, offset: Offset(4, 4)),
              ],
            ),
            child: Text(
              'simulating'.tr,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
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
          BoxShadow(color: Colors.black12, offset: Offset(2, 2)),
        ],
      ),
      child: Text(
        viewTarget.id == 0
            ? 'defending'.tr
            : 'targeting'.trParams({'name': viewTarget.name}),
        style: TextStyle(
          color: viewTarget.id == 0 ? Colors.green[800] : AppColors.redPen,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildLeftSidebar(BuildContext context, GameController game) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'targets'.tr,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const Divider(color: AppColors.ink, thickness: 2),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              itemCount: game.players.length,
              itemBuilder: (ctx, idx) {
                PlayerData p = game.players[idx];
                bool isSelected = game.selectedTargetId == p.id;
                bool isDead = p.isDefeated;

                Color bgColor = isSelected ? AppColors.ink : Colors.white;
                Color textColor = isSelected ? Colors.white : AppColors.ink;
                if (isDead) textColor = Colors.grey;

                return GestureDetector(
                  onTap: isDead ? null : () => game.selectTarget(p.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(
                        color: isDead ? Colors.grey : AppColors.ink,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.ink.withOpacity(0.4),
                                offset: const Offset(3, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isDead
                              ? "${p.name} ☠️"
                              : (p.id == 0 ? 'me'.tr : p.name),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        AspectRatio(
                          aspectRatio: 8 / 6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.ink,
                                width: 1,
                              ),
                            ),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 8,
                                    crossAxisSpacing: 1,
                                    mainAxisSpacing: 1,
                                  ),
                              itemCount: 48,
                              itemBuilder: (ctx, i) {
                                Cell cell = p.board[i]!;
                                Color c = Colors.transparent;
                                if (cell.isRevealed &&
                                    (cell.entity == Entity.ship ||
                                        cell.entity == Entity.turret)) {
                                  c = AppColors.redPen;
                                } else if (p.id == 0 &&
                                    cell.entity != Entity.none &&
                                    !cell.isRevealed) {
                                  c = AppColors.ink.withOpacity(0.5);
                                }
                                return Container(color: c);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: AppColors.ink, thickness: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSystemBtn(
                  icon: Icons.map_outlined,
                  color: AppColors.ink,
                  onTap: () => _showGlobalRadar(context, game),
                ),
                _buildSystemBtn(
                  icon: Icons.bug_report,
                  color: game.isDevMode ? Colors.green[700]! : Colors.grey,
                  onTap: game.toggleDevMode,
                ),
                _buildSystemBtn(
                  icon: game.isAutoTrack ? Icons.videocam : Icons.videocam_off,
                  color: game.isAutoTrack ? AppColors.ink : Colors.grey,
                  onTap: game.toggleAutoTrack,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: game.cycleBotSpeed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.ink, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    game.currentBotSpeed == BotSpeed.fast
                        ? Icons.fast_forward
                        : game.currentBotSpeed == BotSpeed.slow
                        ? Icons.play_arrow
                        : Icons.speed,
                    color: AppColors.ink,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    game.currentBotSpeed == BotSpeed.fast
                        ? 'speed_fast'.tr
                        : game.currentBotSpeed == BotSpeed.slow
                        ? 'speed_slow'.tr
                        : 'speed_normal'.tr,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 24),
      onPressed: onTap,
      splashRadius: 20,
    );
  }

  Widget _buildAnimatedPaperGrid(
    GameController game,
    PlayerData targetPlayer,
    bool isMyTurn,
  ) {
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 7,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.ink, width: 3),
            color: AppColors.paper.withOpacity(0.9),
            boxShadow: const [
              BoxShadow(color: Colors.black26, offset: Offset(4, 4)),
            ],
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 9,
            ),
            itemCount: 63,
            itemBuilder: (context, index) {
              int r = index ~/ 9;
              int c = index % 9;
              if (r == 0 && c == 0) return const SizedBox();
              if (r == 0) return GridHeaderCell('$c');
              if (c == 0) return GridHeaderCell(String.fromCharCode(64 + r));

              int boardIdx = (r - 1) * 8 + (c - 1);
              Cell cell = targetPlayer.board[boardIdx]!;

              return InkWell(
                onTap: () {
                  if (isMyTurn &&
                      targetPlayer.id != 0 &&
                      !targetPlayer.isDefeated) {
                    game.toggleLockTarget(targetPlayer.id, boardIdx);
                  }
                },
                splashColor: Colors.cyanAccent.withOpacity(0.4),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.ink.withOpacity(0.2),
                      width: 1.0,
                    ),
                    color:
                        (cell.terrain == Terrain.land &&
                            (!targetPlayer.isBot || cell.isRevealed))
                        ? Colors.brown[300]!.withOpacity(0.6)
                        : Colors.transparent,
                  ),
                  child: _buildCellGraphics(boardIdx, targetPlayer, game),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCellGraphics(
    int index,
    PlayerData targetPlayer,
    GameController game,
  ) {
    Cell cell = targetPlayer.board[index]!;
    bool isEnemyBoard = targetPlayer.isBot;
    bool isMyBoard = !isEnemyBoard;

    bool isSunk = false;
    if (cell.shipId != null) {
      final matchedShips = targetPlayer.ships.where((s) => s.id == cell.shipId);
      if (matchedShips.isNotEmpty) {
        isSunk = matchedShips.first.isSunk;
      }
    }

    Widget baseContent = const SizedBox();
    bool showBase =
        isMyBoard ||
        game.isDevMode ||
        (isEnemyBoard &&
            cell.isRevealed &&
            (cell.entity == Entity.turret || isSunk));

    if (showBase && cell.entity != Entity.none) {
      if (cell.entity == Entity.turret) {
        baseContent = const Icon(Icons.fort, color: AppColors.ink, size: 22);
      } else if (cell.entity == Entity.ship) {
        baseContent = ConnectedShipPiece(
          index: index,
          shipId: cell.shipId!,
          board: targetPlayer.board,
        );
      }
    }

    if (isEnemyBoard &&
        !cell.isRevealed &&
        game.isDevMode &&
        cell.entity != Entity.none) {
      baseContent = Opacity(opacity: 0.2, child: baseContent);
    }

    Widget overlay = const SizedBox();
    if (cell.isRevealed) {
      if (cell.entity == Entity.ship || cell.entity == Entity.turret) {
        overlay = Center(
          child: TweenAnimationBuilder(
            key: ValueKey('hit_${targetPlayer.id}_$index'),
            duration: const Duration(milliseconds: 700),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, val, child) => Transform.scale(
              scale: val,
              child: Transform.rotate(
                angle: -0.1,
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'X',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.redPen,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        bool isRecentMiss =
            game.activeShotAnimation != null &&
            game.activeShotAnimation!['index'] == index &&
            game.activeShotAnimation!['targetId'] == targetPlayer.id;

        if (isRecentMiss) {
          overlay = Center(
            child: TweenAnimationBuilder(
              key: ValueKey('miss_${targetPlayer.id}_$index'),
              duration: const Duration(milliseconds: 1500),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.easeInQuad,
              builder: (context, val, child) {
                return Transform.scale(
                  scale: 0.5 + (val * 0.3),
                  child: Opacity(
                    opacity: 1.0 - val,
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'O',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      }
    }

    Widget actionAnim = const SizedBox();
    bool isLocked = game.pendingShots.any(
      (shot) =>
          shot['targetId'] == targetPlayer.id && shot['cellIndex'] == index,
    );

    if (isLocked) {
      actionAnim = TweenAnimationBuilder(
        key: ValueKey('lock_${targetPlayer.id}_$index'),
        tween: Tween<double>(begin: 0.8, end: 1.1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, val, child) => Transform.scale(
          scale: val,
          child: const Icon(Icons.gps_not_fixed, color: Colors.cyan, size: 24),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [baseContent, overlay, actionAnim],
    );
  }

  Widget _buildAmmoStatus(GameController game) {
    int locked = game.pendingShots.length;
    PlayerData activePlayer = game.players[game.currentPlayerIndex];
    int totalRemaining = game.remainingShotsInTurn;
    int baseCapacity = activePlayer.activeTurrets + 1;
    int currentBonus = max(0, totalRemaining - baseCapacity);
    int currentBase = totalRemaining - currentBonus;
    int availBase = max(0, currentBase - locked);
    int leftoverLock = max(0, locked - currentBase);
    int availBonus = max(0, currentBonus - leftoverLock);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              Text(
                'ammo_ready'.tr,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              ...List.generate(
                locked,
                (i) => const Icon(
                  Icons.rocket_launch,
                  color: Colors.cyan,
                  size: 20,
                ),
              ),
              ...List.generate(
                availBase,
                (i) => const Icon(
                  Icons.rocket_launch,
                  color: AppColors.ink,
                  size: 20,
                ),
              ),
              ...List.generate(
                availBonus,
                (i) => const Icon(
                  Icons.rocket_launch,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'ammo_legend'.tr,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandConsole(GameController game) {
    bool isMyTurn = game.players[game.currentPlayerIndex].id == 0;

    if (isMyTurn && game.pendingShots.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.cyan.withOpacity(0.05),
          border: Border.all(color: Colors.cyan, width: 2),
        ),
        child: Column(
          children: [
            Text(
              'targets_locked'.tr,
              style: const TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${game.pendingShots.length} / ${game.remainingShotsInTurn}",
              style: const TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.cyan, width: 2),
                    ),
                    onPressed: game.cancelAllLocks,
                    child: const Icon(Icons.close, color: Colors.cyan),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redPen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 4,
                    ),
                    onPressed: game.confirmFire,
                    child: Text(
                      'fire_all'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isMyTurn
              ? Colors.green[800]!.withOpacity(0.1)
              : AppColors.redPen.withOpacity(0.1),
          border: Border.all(
            color: isMyTurn ? Colors.green[800]! : AppColors.redPen,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.white, offset: Offset(2, 2)),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            game.statusMessage,
            key: ValueKey(game.statusMessage),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isMyTurn ? Colors.green[800] : AppColors.redPen,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildHitLogs(GameController game) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: AppColors.ink.withOpacity(0.5), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: AppColors.ink, size: 16),
                const SizedBox(width: 4),
                Text(
                  'battle_log'.tr,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.ink, thickness: 1),
            Expanded(
              child: ListView.builder(
                itemCount: game.hitLogs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TweenAnimationBuilder(
                      key: ValueKey('log_${game.hitLogs.length}_$index'),
                      tween: Tween<double>(begin: -10, end: 0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      builder: (context, val, child) => Transform.translate(
                        offset: Offset(val, 0),
                        child: Opacity(
                          opacity: 1.0 - (val / -10),
                          child: Text(
                            "> ${game.hitLogs[index]}",
                            style: const TextStyle(
                              color: AppColors.redPen,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
                    horizontal: BorderSide(color: AppColors.ink, width: 6),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10)],
                ),
                child: Text(
                  game.turnTransitionMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isMyTurn ? Colors.green[800] : AppColors.redPen,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showGlobalRadar(BuildContext context, GameController game) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.95,
            maxWidth: 1200,
          ),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.paper,
            border: Border.all(color: AppColors.ink, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black26, offset: Offset(8, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Text(
                    'global_radar'.tr,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.ink,
                      size: 28,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(color: AppColors.ink, thickness: 2, height: 8),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: game.players.length,
                  itemBuilder: (ctx, idx) =>
                      _buildRadarThumb(game.players[idx], game),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
