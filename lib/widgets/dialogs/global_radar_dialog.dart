import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../state/game_controller.dart';
import '../../models/game_models.dart';
import '../../utils/constants.dart';

class GlobalRadarDialog extends StatelessWidget {
  final GameController game;
  final VoidCallback playSound;

  const GlobalRadarDialog({
    super.key,
    required this.game,
    required this.playSound,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.95,
            maxWidth: 1200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppColors.paper,
            border: Border.all(color: AppColors.ink, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black26, offset: Offset(8, 8))
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                Text('global_radar'.tr,
                    style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2)),
                IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon:
                        const Icon(Icons.close, color: AppColors.ink, size: 28),
                    onPressed: () {
                      playSound();
                      Get.back();
                    }),
              ],
            ),
            const Divider(color: AppColors.ink, thickness: 2, height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('radar_desc'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic)),
            ),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: game.columns / game.rows,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16),
                itemCount: game.players.length,
                itemBuilder: (ctx, idx) =>
                    RadarThumbWidget(player: game.players[idx], game: game),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RadarThumbWidget extends StatelessWidget {
  final PlayerData player;
  final GameController game;

  const RadarThumbWidget({super.key, required this.player, required this.game});

  Widget _buildXIcon({Color color = AppColors.redPen}) {
    return FractionallySizedBox(
      widthFactor: 0.7,
      heightFactor: 0.7,
      child: FittedBox(child: Icon(Icons.close, color: color)),
    );
  }

  Widget _buildOIcon({Color color = Colors.black54}) {
    return FractionallySizedBox(
      widthFactor: 0.5,
      heightFactor: 0.5,
      child: FittedBox(child: Icon(Icons.radio_button_unchecked, color: color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMe = player.id == 0;
    bool isDead = player.isDefeated;

    bool hideEnemyRadar = !isMe &&
        (game.assistLevel == AssistLevel.hardcore ||
            game.assistLevel == AssistLevel.realLife);

    String displayShips = hideEnemyRadar
        ? "?"
        : player.ships.where((s) => !s.isSunk).length.toString();
    String displayTurrets = hideEnemyRadar
        ? "?"
        : player.board.values
            .where((c) => c.entity == Entity.turret && !c.isRevealed)
            .length
            .toString();

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
          border:
              Border.all(color: isDead ? Colors.grey : AppColors.ink, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black12, offset: Offset(2, 2))
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
            if (!isDead)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_boat,
                        size: 10, color: AppColors.ink.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(displayShips,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink.withOpacity(0.7))),
                    const SizedBox(width: 10),
                    Icon(Icons.fort,
                        size: 10, color: AppColors.ink.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(displayTurrets,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink.withOpacity(0.7))),
                  ],
                ),
              ),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: game.columns / game.rows,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: isDead ? Colors.grey : AppColors.ink,
                          width: 1.5),
                      color: isDead
                          ? Colors.grey.withOpacity(0.2)
                          : Colors.blue[50]!.withOpacity(0.3),
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: game.columns,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                      ),
                      itemCount: game.gridSize,
                      itemBuilder: (ctx, i) {
                        Cell cell = player.board[i]!;
                        Color c = Colors.transparent;

                        if (isMe) {
                          if (cell.isRevealed &&
                              (cell.entity == Entity.ship ||
                                  cell.entity == Entity.turret)) {
                            c = AppColors.redPen;
                          } else if (cell.entity != Entity.none &&
                              !cell.isRevealed) {
                            c = AppColors.ink.withOpacity(0.5);
                          } else if (cell.isRevealed &&
                              cell.entity == Entity.none) {
                            c = Colors.black12;
                          }
                        } else {
                          if (!hideEnemyRadar) {
                            if (cell.isRevealed &&
                                (cell.entity == Entity.ship ||
                                    cell.entity == Entity.turret)) {
                              c = AppColors.redPen;
                            } else if (cell.isRevealed &&
                                cell.entity == Entity.none &&
                                game.assistLevel == AssistLevel.casual) {
                              c = Colors.black87;
                            }
                          }
                        }

                        Widget marker = const SizedBox();
                        if (hideEnemyRadar && !isMe) {
                          String? manual =
                              game.manualMarkers["${player.id}_$i"];
                          if (manual == 'X')
                            marker = _buildXIcon(color: Colors.red);
                          if (manual == 'O')
                            marker = _buildOIcon(color: Colors.black54);
                        }

                        return Container(
                            decoration: BoxDecoration(
                                color: c,
                                border: Border.all(
                                    color: AppColors.ink.withOpacity(0.1),
                                    width: 0.5)),
                            child: marker);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
