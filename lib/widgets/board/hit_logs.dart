import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../state/game_controller.dart';
import '../../utils/constants.dart';

class HitLogsWidget extends StatelessWidget {
  const HitLogsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GameController>(
      builder: (game) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(
                    color: AppColors.ink.withOpacity(0.5), width: 1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long,
                        color: AppColors.ink, size: 16),
                    const SizedBox(width: 4),
                    Text('battle_log'.tr,
                        style: const TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1)),
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
                                  child: Text("> ${game.hitLogs[index]}",
                                      style: const TextStyle(
                                          color: AppColors.redPen,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis))),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
