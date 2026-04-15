import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../state/game_controller.dart';
import '../../models/game_models.dart';
import '../../utils/constants.dart';

class AmmoStatusWidget extends StatelessWidget {
  final GameController game;

  const AmmoStatusWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
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
            BoxShadow(color: Colors.black12, offset: Offset(2, 2))
          ]),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              Text('ammo_ready'.tr,
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w900)),
              ...List.generate(
                  locked,
                  (i) => const Icon(Icons.rocket_launch,
                      color: Colors.cyan, size: 20)),
              ...List.generate(
                  availBase,
                  (i) => const Icon(Icons.rocket_launch,
                      color: AppColors.ink, size: 20)),
              ...List.generate(
                  availBonus,
                  (i) => const Icon(Icons.rocket_launch,
                      color: Colors.orange, size: 20)),
            ],
          ),
          const SizedBox(height: 4),
          Text('ammo_legend'.tr,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
