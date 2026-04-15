import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../state/game_controller.dart';
import '../../models/game_models.dart';
import '../../utils/constants.dart';

class LeftSidebarWidget extends StatelessWidget {
  final GameController game;
  final VoidCallback playSound;
  final VoidCallback onShowRadar;

  const LeftSidebarWidget({
    super.key,
    required this.game,
    required this.playSound,
    required this.onShowRadar,
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

  Widget _buildSystemBtn(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return IconButton(
        icon: Icon(icon, color: color, size: 24),
        onPressed: onTap,
        splashRadius: 20);
  }

  @override
  Widget build(BuildContext context) {
    String astName = '';
    if (game.assistLevel == AssistLevel.casual) astName = 'ast_casual'.tr;
    if (game.assistLevel == AssistLevel.standard) astName = 'ast_standard'.tr;
    if (game.assistLevel == AssistLevel.hardcore) astName = 'ast_hardcore'.tr;
    if (game.assistLevel == AssistLevel.realLife) astName = 'ast_reallife'.tr;

    String diffName = '';
    if (game.botDifficulty == BotDifficulty.easy) diffName = 'diff_easy'.tr;
    if (game.botDifficulty == BotDifficulty.normal) diffName = 'diff_normal'.tr;
    if (game.botDifficulty == BotDifficulty.hard) diffName = 'diff_hard'.tr;
    bool hasBot = game.players.any((p) => p.isBot);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text('targets'.tr,
              style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 16)),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasBot) ...[
                const Icon(Icons.smart_toy, size: 10, color: AppColors.ink),
                const SizedBox(width: 2),
                Text(diffName.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink)),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.handshake, size: 10, color: AppColors.ink),
              const SizedBox(width: 2),
              Text(astName.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink)),
            ],
          ),
          const SizedBox(height: 2),
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

                bool hideEnemyRadar = p.id != 0 &&
                    (game.assistLevel == AssistLevel.hardcore ||
                        game.assistLevel == AssistLevel.realLife);

                String displayShips = hideEnemyRadar
                    ? "?"
                    : p.ships.where((s) => !s.isSunk).length.toString();
                String displayTurrets = hideEnemyRadar
                    ? "?"
                    : p.board.values
                        .where(
                            (c) => c.entity == Entity.turret && !c.isRevealed)
                        .length
                        .toString();

                return GestureDetector(
                  onTap: isDead
                      ? null
                      : () {
                          playSound();
                          game.selectTarget(p.id);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(
                          color: isDead ? Colors.grey : AppColors.ink,
                          width: isSelected ? 2 : 1),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: AppColors.ink.withOpacity(0.4),
                                  offset: const Offset(3, 3))
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
                              fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isDead)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_boat,
                                    size: 10,
                                    color: isSelected
                                        ? Colors.white70
                                        : AppColors.ink.withOpacity(0.6)),
                                const SizedBox(width: 2),
                                Text(displayShips,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white70
                                            : AppColors.ink.withOpacity(0.6))),
                                const SizedBox(width: 8),
                                Icon(Icons.fort,
                                    size: 10,
                                    color: isSelected
                                        ? Colors.white70
                                        : AppColors.ink.withOpacity(0.6)),
                                const SizedBox(width: 2),
                                Text(displayTurrets,
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white70
                                            : AppColors.ink.withOpacity(0.6))),
                              ],
                            ),
                          ),
                        AspectRatio(
                          aspectRatio: game.columns / game.rows,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.ink,
                                    width: 1)),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: game.columns,
                                      crossAxisSpacing: 0,
                                      mainAxisSpacing: 0),
                              itemCount: game.gridSize,
                              itemBuilder: (ctx, i) {
                                Cell cell = p.board[i]!;
                                Color c = Colors.transparent;

                                if (p.id == 0) {
                                  if (cell.isRevealed &&
                                      (cell.entity == Entity.ship ||
                                          cell.entity == Entity.turret)) {
                                    c = AppColors.redPen;
                                  } else if (cell.entity != Entity.none &&
                                      !cell.isRevealed) {
                                    c = AppColors.ink.withOpacity(0.5);
                                  }
                                } else {
                                  if (!hideEnemyRadar) {
                                    if (cell.isRevealed &&
                                        (cell.entity == Entity.ship ||
                                            cell.entity == Entity.turret)) {
                                      c = AppColors.redPen;
                                    } else if (cell.isRevealed &&
                                        cell.entity == Entity.none &&
                                        game.assistLevel ==
                                            AssistLevel.casual) {
                                      c = Colors.black87;
                                    }
                                  }
                                }

                                Widget marker = const SizedBox();
                                if (hideEnemyRadar && p.id != 0) {
                                  String? manual =
                                      game.manualMarkers["${p.id}_$i"];
                                  if (manual == 'X')
                                    marker = _buildXIcon(color: Colors.red);
                                  if (manual == 'O')
                                    marker = _buildOIcon(color: Colors.black54);
                                }

                                return Container(
                                    decoration: BoxDecoration(
                                        color: c,
                                        border: Border.all(
                                            color:
                                                AppColors.ink.withOpacity(0.1),
                                            width: 0.5)),
                                    child: marker);
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
                    onTap: () {
                      playSound();
                      onShowRadar();
                    }),
                _buildSystemBtn(
                    icon:
                        game.isAutoTrack ? Icons.videocam : Icons.videocam_off,
                    color: game.isAutoTrack ? AppColors.ink : Colors.grey,
                    onTap: () {
                      playSound();
                      game.toggleAutoTrack();
                    }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              playSound();
              game.cycleBotSpeed();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.ink, width: 1.5),
                  borderRadius: BorderRadius.circular(4)),
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
                      size: 16),
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
                          fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
