import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../state/game_controller.dart';
import '../../state/sound_controller.dart';
import '../../models/game_models.dart';
import '../../utils/constants.dart';
import '../shared/connected_ship_piece.dart';
import '../shared/floating_joke_widget.dart'; // 👈 Import ตัวนี้มาแทนที่

class InteractiveGridWidget extends StatefulWidget {
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

  @override
  State<InteractiveGridWidget> createState() => _InteractiveGridWidgetState();
}

class _InteractiveGridWidgetState extends State<InteractiveGridWidget> {
  Offset? _lastTapPosition;

  // --- Easter Egg Trackers ---
  bool _isCursedEFBoard = false; // ถ้าสุ่มได้ true แถว E กับ F จะสลับกัน
  int _efTapCount = 0;

  final Map<int, int> _friendlyFireCount = {};
  final Map<int, int> _feedFishCount = {};

  @override
  void initState() {
    super.initState();
    // สุ่มความน่าจะเป็น 15% ที่กระดานนี้ แถว E กับ F จะสลับตัวอักษรกัน (อิงตาม Hash ของเกมเพื่อไม่ให้มันกระพริบตอน Scroll)
    _isCursedEFBoard = Random(widget.game.hashCode).nextDouble() < 0.15;
  }

  void _triggerJoke(String message, IconData icon) {
    if (_lastTapPosition == null) return;

    if (Get.isRegistered<SoundController>()) {
      Get.find<SoundController>().vibrateHeavy();
      Get.find<SoundController>().playError();
    }

    final overlayState = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => FloatingJokeWidget(
        message: message,
        icon: icon,
        startPosition: _lastTapPosition!,
        onComplete: () => entry.remove(),
      ),
    );

    overlayState.insert(entry);
  }

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
    bool isMyBoard = widget.targetPlayer.id == 0;
    bool hideEnemyLand = !isMyBoard &&
        (widget.game.assistLevel == AssistLevel.hardcore ||
            widget.game.assistLevel == AssistLevel.realLife);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          widget.onConstraintsBuilt(constraints);
          return InteractiveViewer(
            transformationController: widget.transformCtrl,
            minScale: 1.0,
            maxScale: 4.0,
            boundaryMargin: EdgeInsets.zero,
            child: Center(
              child: AspectRatio(
                aspectRatio: (widget.game.columns + 1) / (widget.game.rows + 1),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.ink.withOpacity(0.5), width: 2.5),
                      color: AppColors.paper.withOpacity(0.85)),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.game.columns + 1),
                    itemCount:
                        (widget.game.columns + 1) * (widget.game.rows + 1),
                    itemBuilder: (context, index) {
                      int r = index ~/ (widget.game.columns + 1);
                      int c = index % (widget.game.columns + 1);

                      if (r == 0 && c == 0) return const SizedBox();
                      if (r == 0) return GridHeaderCell('$c');

                      if (c == 0) {
                        String rowChar = String.fromCharCode(64 + r);
                        // 🥚 Easter Egg: สลับ E กับ F
                        if (_isCursedEFBoard) {
                          if (r == 5) rowChar = 'F';
                          if (r == 6) rowChar = 'E';
                        }
                        return GridHeaderCell(rowChar);
                      }

                      int boardIdx = (r - 1) * widget.game.columns + (c - 1);
                      Cell cell = widget.targetPlayer.board[boardIdx]!;

                      bool showLand = false;
                      double landOpacity = 1.0;

                      if (cell.terrain == Terrain.land) {
                        if (isMyBoard || (cell.isRevealed && !hideEnemyLand)) {
                          showLand = true;
                        } else if (widget.game.isDevMode && !isMyBoard) {
                          showLand = true;
                          landOpacity = 0.3;
                        }
                      }

                      return InkWell(
                        onTapDown: (details) {
                          _lastTapPosition = details
                              .globalPosition; // 👈 เก็บพิกัดไว้เด้ง Joke
                        },
                        onTap: () {
                          // 🥚 Easter Egg: กดแถว E หรือ F บ่อยๆ
                          if (!isMyBoard && (r == 5 || r == 6)) {
                            _efTapCount++;
                            if (_efTapCount >= 6) {
                              _triggerJoke('ee_e_or_f'.tr, Icons.spellcheck);
                              _efTapCount = 0;
                            }
                          }

                          if (widget.isMyTurn &&
                              !isMyBoard &&
                              !widget.targetPlayer.isDefeated) {
                            // 🥚 Easter Egg: ยิงซ้ำที่น้ำ (ให้อาหารปลา)
                            if (cell.isRevealed && cell.entity == Entity.none) {
                              _feedFishCount[boardIdx] =
                                  (_feedFishCount[boardIdx] ?? 0) + 1;
                              if (_feedFishCount[boardIdx]! >= 3) {
                                _triggerJoke('ee_feed_fish'.tr, Icons.set_meal);
                                _feedFishCount[boardIdx] = 0;
                              } else {
                                widget.playSound();
                              }
                            } else {
                              widget.game.toggleLockTarget(
                                  widget.targetPlayer.id, boardIdx);
                            }
                          } else if (isMyBoard && widget.isMyTurn) {
                            // 🥚 Easter Egg: กดยิงเรือฝั่งตัวเอง (Friendly Fire)
                            if (cell.entity == Entity.ship) {
                              _friendlyFireCount[boardIdx] =
                                  (_friendlyFireCount[boardIdx] ?? 0) + 1;
                              if (_friendlyFireCount[boardIdx]! >= 3) {
                                _triggerJoke('ee_friendly_fire'.tr,
                                    Icons.warning_rounded);
                                _friendlyFireCount[boardIdx] = 0;
                              } else {
                                widget.playSound();
                              }
                            }
                          } else if (widget.game.assistLevel ==
                                  AssistLevel.realLife &&
                              !isMyBoard) {
                            widget.playSound();
                            widget.game.toggleManualMarker(
                                widget.targetPlayer.id, boardIdx);
                          }
                        },
                        onLongPress: () {
                          if (widget.game.assistLevel == AssistLevel.realLife &&
                              !isMyBoard) {
                            widget.playSound();
                            widget.game.toggleManualMarker(
                                widget.targetPlayer.id, boardIdx);
                          }
                        },
                        splashColor: Colors.cyanAccent.withOpacity(0.3),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.ink.withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              if (showLand)
                                Opacity(
                                  opacity: landOpacity,
                                  child: ThemedLandPiece(
                                    index: boardIdx,
                                    board: widget.targetPlayer.board,
                                    columns: widget.game.columns,
                                  ),
                                ),
                              Center(
                                child: _buildCellGraphics(
                                    boardIdx, widget.targetPlayer, widget.game),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ink.withOpacity(0.05),
        border: Border.all(
          color: AppColors.ink.withOpacity(0.2),
          width: 0.5,
        ),
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
