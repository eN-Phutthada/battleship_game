import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../state/game_controller.dart';
import '../../utils/constants.dart';

class CommandConsoleWidget extends StatelessWidget {
  final GameController game;
  final VoidCallback playSound;

  const CommandConsoleWidget(
      {super.key, required this.game, required this.playSound});

  @override
  Widget build(BuildContext context) {
    bool isMyTurn = game.players[game.currentPlayerIndex].id == 0;

    if (game.isWaitingAck) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            border: Border.all(color: Colors.orange[800]!, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.white, offset: Offset(2, 2))
            ]),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 4),
          onPressed: () {
            playSound();
            game.acknowledgeTurn();
          },
          icon: const Icon(Icons.edit_note, color: Colors.white),
          label: Text('btn_ack'.tr,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.0)),
        ),
      );
    }

    if (isMyTurn && game.pendingShots.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.05),
            border: Border.all(color: Colors.cyan, width: 2)),
        child: Column(
          children: [
            Text('targets_locked'.tr,
                style: const TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.w900,
                    fontSize: 14)),
            const SizedBox(height: 4),
            Text("${game.pendingShots.length} / ${game.remainingShotsInTurn}",
                style: const TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    letterSpacing: 2)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side:
                                const BorderSide(color: Colors.cyan, width: 2)),
                        onPressed: () {
                          playSound();
                          game.cancelAllLocks();
                        },
                        child: const Icon(Icons.close, color: Colors.cyan))),
                const SizedBox(width: 8),
                Expanded(
                    flex: 2,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.redPen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 4),
                        onPressed: () {
                          playSound();
                          game.confirmFire();
                        },
                        child: Text('fire_all'.tr,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1.5)))),
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
                width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.white, offset: Offset(2, 2))
            ]),
        child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(game.statusMessage,
                key: ValueKey(game.statusMessage),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isMyTurn ? Colors.green[800] : AppColors.redPen,
                    fontSize: 15,
                    fontWeight: FontWeight.w900))),
      );
    }
  }
}
