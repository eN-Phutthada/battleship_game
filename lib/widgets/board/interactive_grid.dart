import 'dart:math';
import 'package:flutter/material.dart';

import '../../state/game_controller.dart';
import '../../models/game_models.dart';
import '../../utils/constants.dart';
// ตรวจสอบให้แน่ใจว่า ConnectedShipPiece, TurretPiece, ThemedLandPiece
// ถูก import มาจากไฟล์ที่ถูกต้อง (เช่น themed_pieces.dart หรือ connected_ship_piece.dart)
import '../shared/connected_ship_piece.dart';

class InteractiveGridWidget extends StatelessWidget {
  final GameController game;
  final PlayerData targetPlayer;
  final bool isMyTurn;
  final TransformationController transformCtrl;
  final Function(BoxConstraints) onConstraintsBuilt;
  final VoidCallback playSound;

  const InteractiveGridWidget({
    super.key,
    required this.game,
    required this.targetPlayer,
    required this.isMyTurn,
    required this.transformCtrl,
    required this.onConstraintsBuilt,
    required this.playSound,
  });

  Widget _buildXIcon({Color color = AppColors.redPen}) {
    return FractionallySizedBox(
        widthFactor: 0.7,
        heightFactor: 0.7,
        child: FittedBox(child: Icon(Icons.close, color: color)));
  }

  Widget _buildOIcon({Color color = Colors.black54}) {
    return FractionallySizedBox(
        widthFactor: 0.5,
        heightFactor: 0.5,
        child:
            FittedBox(child: Icon(Icons.radio_button_unchecked, color: color)));
  }

  @override
  Widget build(BuildContext context) {
    bool isMyBoard = targetPlayer.id == 0;
    bool hideEnemyLand = !isMyBoard &&
        (game.assistLevel == AssistLevel.hardcore ||
            game.assistLevel == AssistLevel.realLife);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          onConstraintsBuilt(constraints);
          return InteractiveViewer(
            transformationController: transformCtrl,
            minScale: 1.0,
            maxScale: 4.0,
            boundaryMargin: EdgeInsets.zero,
            child: Center(
              child: AspectRatio(
                aspectRatio: (game.columns + 1) / (game.rows + 1),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.ink.withOpacity(0.5), width: 2.5),
                      color: AppColors.paper.withOpacity(0.85)),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: game.columns + 1),
                    itemCount: (game.columns + 1) * (game.rows + 1),
                    itemBuilder: (context, index) {
                      int r = index ~/ (game.columns + 1);
                      int c = index % (game.columns + 1);

                      if (r == 0 && c == 0) return const SizedBox();
                      if (r == 0) return GridHeaderCell('$c');
                      if (c == 0)
                        return GridHeaderCell(String.fromCharCode(64 + r));

                      int boardIdx = (r - 1) * game.columns + (c - 1);
                      Cell cell = targetPlayer.board[boardIdx]!;

                      bool showLand = false;
                      double landOpacity = 1.0;

                      if (cell.terrain == Terrain.land) {
                        if (isMyBoard || (cell.isRevealed && !hideEnemyLand)) {
                          showLand = true;
                        } else if (game.isDevMode && !isMyBoard) {
                          showLand = true;
                          landOpacity = 0.3;
                        }
                      }

                      return InkWell(
                        onTap: () {
                          if (isMyTurn &&
                              !isMyBoard &&
                              !targetPlayer.isDefeated) {
                            game.toggleLockTarget(targetPlayer.id, boardIdx);
                          } else if (game.assistLevel == AssistLevel.realLife &&
                              !isMyBoard) {
                            playSound();
                            game.toggleManualMarker(targetPlayer.id, boardIdx);
                          }
                        },
                        onLongPress: () {
                          if (game.assistLevel == AssistLevel.realLife &&
                              !isMyBoard) {
                            playSound();
                            game.toggleManualMarker(targetPlayer.id, boardIdx);
                          }
                        },
                        splashColor: Colors.cyanAccent.withOpacity(0.3),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 1. Layer แผ่นดิน (Land) - แสดงผลตามธีมและโหมด Dev
                              if (showLand)
                                Opacity(
                                  opacity: landOpacity,
                                  child: ThemedLandPiece(
                                    index: boardIdx,
                                    board: targetPlayer.board,
                                    columns: game.columns,
                                  ),
                                ),

                              // 2. ✨ Layer เส้นตาราง (Faint Grid Lines) บนแผ่นดิน ✨
                              // เราใช้ Opacity ต่ำๆ เพื่อให้เห็นเส้นจางๆ
                              if (showLand)
                                Opacity(
                                  opacity:
                                      0.1, // ปรับความจางของเส้นตารางบนแผ่นดินที่นี่ (0.0 - 1.0)
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.ink,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                ),

                              // 3. Layer เส้นตารางหลัก (Main Grid Lines) - สำหรับพื้นที่ที่ไม่ใช่ Land
                              if (!showLand)
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.ink.withOpacity(
                                          0.2), // ความชัดเจนของเส้นตารางปกติ
                                      width: 0.5,
                                    ),
                                  ),
                                ),

                              // 4. Layer เนื้อหา (Cell Graphics) วางทับด้านบนสุด
                              Center(
                                child: _buildCellGraphics(
                                    boardIdx, targetPlayer, game),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCellGraphics(
      int index, PlayerData targetPlayer, GameController game) {
    Cell cell = targetPlayer.board[index]!;
    bool isEnemyBoard = targetPlayer.id != 0;
    bool isMyBoard = !isEnemyBoard;

    bool isSunk = false;
    if (cell.shipId != null) {
      try {
        isSunk =
            targetPlayer.ships.firstWhere((s) => s.id == cell.shipId).isSunk;
      } catch (e) {}
    }

    Widget baseContent = const SizedBox();
    bool showBase = isMyBoard ||
        game.isDevMode ||
        (isEnemyBoard &&
            cell.isRevealed &&
            (cell.entity == Entity.turret || isSunk) &&
            game.assistLevel != AssistLevel.realLife &&
            game.assistLevel != AssistLevel.hardcore);

    if (showBase && cell.entity != Entity.none) {
      if (cell.entity == Entity.turret) {
        baseContent = const TurretPiece();
      } else if (cell.entity == Entity.ship) {
        baseContent = ConnectedShipPiece(
            index: index,
            shipId: cell.shipId!,
            board: targetPlayer.board,
            columns: game.columns);
      }
    }

    if (isEnemyBoard &&
        !cell.isRevealed &&
        game.isDevMode &&
        cell.entity != Entity.none) {
      baseContent = Opacity(opacity: 0.2, child: baseContent);
    }

    Widget manualMarker = const SizedBox();
    if (game.assistLevel == AssistLevel.realLife && isEnemyBoard) {
      String? marker = game.manualMarkers["${targetPlayer.id}_$index"];
      if (marker == 'X') {
        manualMarker = _buildXIcon(color: Colors.redAccent);
      } else if (marker == 'O') {
        manualMarker = _buildOIcon(color: AppColors.ink.withOpacity(0.6));
      }
    }

    Widget overlay = const SizedBox();
    if (cell.isRevealed) {
      bool isRecentAction = game.activeShotAnimation != null &&
          game.activeShotAnimation!['index'] == index &&
          game.activeShotAnimation!['targetId'] == targetPlayer.id;
      bool isHitReal =
          cell.entity == Entity.ship || cell.entity == Entity.turret;
      bool showHit = isMyBoard ||
          (game.assistLevel != AssistLevel.realLife) ||
          isRecentAction;
      bool showMiss = isMyBoard ||
          (game.assistLevel == AssistLevel.casual) ||
          isRecentAction;

      if ((isHitReal && showHit) || (!isHitReal && showMiss)) {
        if (isRecentAction && game.assistLevel != AssistLevel.realLife) {
          overlay = TweenAnimationBuilder(
              key: ValueKey('anim_$index'),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, val, child) {
                if (val < 0.5) {
                  return Transform.scale(
                      scale: 0.5 + (val * 1.5),
                      child:
                          _buildOIcon(color: AppColors.ink.withOpacity(0.7)));
                } else {
                  double popScale = 1.0 + sin((val - 0.5) * pi / 0.5) * 0.4;
                  return Transform.scale(
                      scale: popScale,
                      child: isHitReal
                          ? _buildXIcon()
                          : _buildOIcon(color: AppColors.ink.withOpacity(0.7)));
                }
              });
        } else {
          if (isHitReal && showHit) {
            overlay = _buildXIcon();
          } else if (!isHitReal && showMiss) {
            overlay = _buildOIcon(color: AppColors.ink.withOpacity(0.7));
          }
        }
      }
    }

    Widget actionAnim = const SizedBox();
    bool isLocked = game.pendingShots.any((shot) =>
        shot['targetId'] == targetPlayer.id && shot['cellIndex'] == index);
    if (isLocked) {
      actionAnim = TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.8, end: 1.1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          builder: (context, val, child) => Transform.scale(
              scale: val,
              child: const FractionallySizedBox(
                  widthFactor: 0.8,
                  heightFactor: 0.8,
                  child: FittedBox(
                      child: Icon(Icons.gps_not_fixed, color: Colors.cyan)))));
    }

    return Stack(
        alignment: Alignment.center,
        children: [baseContent, manualMarker, overlay, actionAnim]);
  }
}

class GridHeaderCell extends StatelessWidget {
  final String text;
  const GridHeaderCell(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    // ปรับให้ GridHeader มีความหนาของเส้นตารางเข้ากันได้พอดี
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ink.withOpacity(0.05),
        border: Border.all(color: AppColors.ink.withOpacity(0.2), width: 0.5),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
