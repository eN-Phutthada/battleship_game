import 'dart:async';
import 'dart:math';
import 'package:battleship_game/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/game_models.dart';

enum BotSpeed { slow, normal, fast }

class GameController extends GetxController {
  final int columns = 8;
  final int rows = 6;
  int get gridSize => columns * rows;

  List<PlayerData> players = [];
  int currentPlayerIndex = 0;

  Map<int, int> turnShotsFiredAt = {};
  int remainingShotsInTurn = 0;
  bool isGameOver = false;
  String statusMessage = "";
  List<String> hitLogs = [];

  int selectedTargetId = 1;
  bool isDevMode = false;
  bool isDeploying = false;
  Map<String, dynamic>? activeShotAnimation;

  bool isTurnTransition = false;
  bool isWaitingTurnEnd = false;
  String turnTransitionMessage = "";
  List<Map<String, int>> pendingShots = [];

  bool isAutoTrack = true;

  BotSpeed currentBotSpeed = BotSpeed.normal;
  int get botSpeedMs => currentBotSpeed == BotSpeed.slow
      ? 1500
      : (currentBotSpeed == BotSpeed.fast ? 400 : 1000);

  void toggleDevMode() {
    isDevMode = !isDevMode;
    update();
  }

  void toggleAutoTrack() {
    HapticFeedback.lightImpact();
    isAutoTrack = !isAutoTrack;
    update();
  }

  void cycleBotSpeed() {
    HapticFeedback.lightImpact();
    currentBotSpeed =
        BotSpeed.values[(currentBotSpeed.index + 1) % BotSpeed.values.length];
    update();
  }

  void startGame(
    Map<int, Cell> humanBoard,
    List<ShipData> humanShips,
    int enemyCount,
    String pName,
  ) {
    players.clear();
    hitLogs.clear();
    isGameOver = false;
    isDeploying = true;
    isWaitingTurnEnd = false;
    statusMessage = "SIMULATING ENEMY PLACEMENT...";
    pendingShots.clear();
    currentBotSpeed = BotSpeed.normal;
    isAutoTrack = true;

    var human = PlayerData(id: 0, name: pName, isBot: false);
    human.board = _cloneBoard(humanBoard);
    human.ships = List.from(humanShips);
    players.add(human);

    update();

    Future.delayed(const Duration(milliseconds: 1500), () {
      for (int i = 1; i <= enemyCount; i++) {
        var bot = PlayerData(id: i, name: "Bot $i", isBot: true);
        _generateBotBoard(bot);
        players.add(bot);
      }
      isDeploying = false;
      selectedTargetId = 1;
      currentPlayerIndex = 0;
      _startTurn();
    });
  }

  void selectTarget(int botId) {
    selectedTargetId = botId;
    update();
  }

  Map<int, Cell> _cloneBoard(Map<int, Cell> source) {
    return source.map(
      (key, value) => MapEntry(
        key,
        Cell(
          terrain: value.terrain,
          entity: value.entity,
          isRevealed: value.isRevealed,
          shipId: value.shipId,
        ),
      ),
    );
  }

  void _generateBotBoard(PlayerData bot) {
    bot.board = {for (var i = 0; i < gridSize; i++) i: Cell()};
    List<int> botLand = [0, 1, 2, 8, 9, 10, 5, 6, 13, 14, 21, 22];
    for (int idx in botLand) bot.board[idx]!.terrain = Terrain.land;
    bot.board[1]!.entity = Entity.turret;
    bot.board[9]!.entity = Entity.turret;
    bot.board[14]!.entity = Entity.turret;

    List<int> fleet = [4, 3, 2, 1, 1];
    Random r = Random();

    for (int size in fleet) {
      bool placed = false;
      while (!placed) {
        bool isHorizontal = r.nextBool();
        int startPos = r.nextInt(gridSize);
        int rr = startPos ~/ columns;
        int cc = startPos % columns;
        List<int> target = [];
        bool canPlace = true;
        for (int i = 0; i < size; i++) {
          if (isHorizontal) {
            if (cc + i >= columns) {
              canPlace = false;
              break;
            }
            target.add(rr * columns + (cc + i));
          } else {
            if (rr + i >= rows) {
              canPlace = false;
              break;
            }
            target.add((rr + i) * columns + cc);
          }
        }
        if (canPlace) {
          for (int pos in target) {
            if (bot.board[pos]!.terrain != Terrain.water ||
                bot.board[pos]!.entity != Entity.none)
              canPlace = false;
          }
        }
        if (canPlace) {
          String newShipId =
              'bot_${bot.id}_ship_${DateTime.now().microsecondsSinceEpoch}_$size';
          bot.ships.add(ShipData(id: newShipId, size: size, positions: target));
          for (int pos in target) {
            bot.board[pos]!.entity = Entity.ship;
            bot.board[pos]!.shipId = newShipId;
          }
          placed = true;
        }
      }
    }
  }

  bool canLockTarget(int targetPlayerId) {
    if (targetPlayerId == players[currentPlayerIndex].id) return false;
    if (players.firstWhere((p) => p.id == targetPlayerId).isDefeated)
      return false;

    int simulatedShotsThisTarget =
        (turnShotsFiredAt[targetPlayerId] ?? 0) +
        pendingShots.where((s) => s['targetId'] == targetPlayerId).length;
    int minShotsAtAnyTarget = 999;

    for (var p in players) {
      if (p.id != players[currentPlayerIndex].id && !p.isDefeated) {
        int s =
            (turnShotsFiredAt[p.id] ?? 0) +
            pendingShots.where((shot) => shot['targetId'] == p.id).length;
        if (s < minShotsAtAnyTarget) minShotsAtAnyTarget = s;
      }
    }
    return simulatedShotsThisTarget == minShotsAtAnyTarget;
  }

  void toggleLockTarget(int targetPlayerId, int cellIndex) {
    if (players[currentPlayerIndex].isBot ||
        isGameOver ||
        isTurnTransition ||
        isWaitingTurnEnd)
      return;

    int existingIndex = pendingShots.indexWhere(
      (s) => s['targetId'] == targetPlayerId && s['cellIndex'] == cellIndex,
    );
    if (existingIndex != -1) {
      pendingShots.removeAt(existingIndex);
      HapticFeedback.lightImpact();
      update();
      return;
    }

    if (pendingShots.length >= remainingShotsInTurn) return;
    if (players
        .firstWhere((p) => p.id == targetPlayerId)
        .board[cellIndex]!
        .isRevealed)
      return;

    if (!canLockTarget(targetPlayerId)) {
      HapticFeedback.vibrate();

      int? nextTargetId;
      for (var p in players) {
        if (p.id != players[currentPlayerIndex].id && !p.isDefeated) {
          if (canLockTarget(p.id)) {
            nextTargetId = p.id;
            break;
          }
        }
      }

      if (nextTargetId != null && nextTargetId != selectedTargetId) {
        selectedTargetId = nextTargetId;
        update();
      }

      Get.rawSnackbar(
        messageText: Text(
          'distribute_shots'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.paper,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: AppColors.redPen.withOpacity(0.9),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.only(bottom: 100, left: 200, right: 200),
        borderRadius: 20,
        duration: const Duration(milliseconds: 1000),
      );
      return;
    }

    HapticFeedback.lightImpact();
    pendingShots.add({'targetId': targetPlayerId, 'cellIndex': cellIndex});
    update();
  }

  void cancelAllLocks() {
    pendingShots.clear();
    HapticFeedback.lightImpact();
    update();
  }

  void confirmFire() async {
    if (pendingShots.isEmpty || isWaitingTurnEnd) return;

    List<Map<String, int>> shotsToFire = List.from(pendingShots);
    pendingShots.clear();
    update();

    for (var shot in shotsToFire) {
      _executeShoot(shot['targetId']!, shot['cellIndex']!);

      await Future.delayed(Duration(milliseconds: botSpeedMs ~/ 2));
    }
  }

  void _executeShoot(int targetPlayerId, int cellIndex) {
    if (remainingShotsInTurn <= 0 || isGameOver) return;

    var targetPlayer = players.firstWhere((p) => p.id == targetPlayerId);
    var cell = targetPlayer.board[cellIndex]!;
    if (cell.isRevealed) return;

    cell.isRevealed = true;
    turnShotsFiredAt[targetPlayerId] =
        (turnShotsFiredAt[targetPlayerId] ?? 0) + 1;
    remainingShotsInTurn--;

    if (isAutoTrack) {
      selectedTargetId = targetPlayerId;
    }

    bool isShooterMe = players[currentPlayerIndex].id == 0;
    bool isTargetMe = targetPlayerId == 0;
    String shooterName = players[currentPlayerIndex].name;
    String targetName = targetPlayer.name;
    bool isHit = (cell.entity == Entity.ship || cell.entity == Entity.turret);

    final String shotId = DateTime.now().microsecondsSinceEpoch.toString();

    activeShotAnimation = {
      'id': shotId,
      'targetId': targetPlayerId,
      'index': cellIndex,
      'isHit': isHit,
    };
    update();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (activeShotAnimation != null && activeShotAnimation!['id'] == shotId) {
        activeShotAnimation = null;
        update();
      }
    });

    if (cell.entity == Entity.ship) {
      HapticFeedback.heavyImpact();
      ShipData hitShip = targetPlayer.ships.firstWhere(
        (s) => s.id == cell.shipId,
      );
      bool isShipSunk = hitShip.positions.every(
        (pos) => targetPlayer.board[pos]!.isRevealed,
      );
      if (isShipSunk) {
        hitShip.isSunk = true;
        if (isShooterMe) {
          _addLog(
            'log_sunk_me'.trParams({
              'target': targetName,
              'size': hitShip.size.toString(),
            }),
          );
        } else {
          _addLog(
            isTargetMe
                ? 'log_sunk_you'.trParams({'shooter': shooterName})
                : 'log_sunk_enemy'.trParams({
                    'shooter': shooterName,
                    'target': targetName,
                  }),
          );
        }
      } else {
        if (isShooterMe) {
          _addLog('log_hit_me'.trParams({'target': targetName}));
        } else {
          _addLog(
            isTargetMe
                ? 'log_hit_you'.trParams({'shooter': shooterName})
                : 'log_hit_enemy'.trParams({
                    'shooter': shooterName,
                    'target': targetName,
                  }),
          );
        }
      }
    } else if (cell.entity == Entity.turret) {
      HapticFeedback.mediumImpact();
      if (isShooterMe)
        _addLog('log_turret_me'.trParams({'target': targetName}));
      else {
        _addLog(
          isTargetMe
              ? 'log_turret_you'.trParams({'shooter': shooterName})
              : 'log_turret_enemy'.trParams({
                  'shooter': shooterName,
                  'target': targetName,
                }),
        );
      }
    } else {
      HapticFeedback.lightImpact();
    }

    if (cell.terrain == Terrain.land && cell.entity == Entity.none)
      targetPlayer.bonusAmmo++;
    _checkWinCondition();

    if (remainingShotsInTurn <= 0 && pendingShots.isEmpty && !isGameOver) {
      isWaitingTurnEnd = true;
      update();
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!isGameOver) _endTurn();
      });
    } else {
      update();
    }
  }

  void _checkWinCondition() {
    var activePlayers = players.where((p) => !p.isDefeated).toList();
    if (activePlayers.length <= 1) {
      isGameOver = true;
      statusMessage = 'war_over'.tr;
      String winner = activePlayers.isNotEmpty
          ? activePlayers.first.name
          : "NOBODY";
      HapticFeedback.vibrate();

      Future.delayed(const Duration(milliseconds: 800), () {
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                border: Border.all(color: const Color(0xFF000080), width: 4),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, offset: Offset(6, 6)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    activePlayers.first.id == 0
                        ? Icons.emoji_events
                        : Icons.sentiment_very_dissatisfied,
                    size: 48,
                    color: const Color(0xFFD32F2F),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'war_over'.tr,
                    style: const TextStyle(
                      color: Color(0xFF000080),
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                  const Divider(color: Color(0xFF000080), thickness: 2),
                  const SizedBox(height: 8),
                  Text(
                    'wins'.trParams({'name': winner}),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF000080),
                        shape: const RoundedRectangleBorder(),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.offAllNamed('/');
                      },
                      child: Text(
                        'return_base'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      });
    }
  }

  void _startTurn() {
    if (isGameOver) return;
    pendingShots.clear();
    isWaitingTurnEnd = false;
    var activePlayer = players[currentPlayerIndex];

    if (activePlayer.isBot) {
      selectedTargetId = 0;
    } else {
      if (players
          .firstWhere((p) => p.id == selectedTargetId, orElse: () => players[1])
          .isDefeated) {
        var aliveEnemies = players.where((p) => p.isBot && !p.isDefeated);
        if (aliveEnemies.isNotEmpty)
          selectedTargetId = aliveEnemies.first.id;
        else
          selectedTargetId = 0;
      }
    }

    remainingShotsInTurn = activePlayer.currentAmmo;
    activePlayer.bonusAmmo = 0;
    turnShotsFiredAt.clear();
    statusMessage = 'turn_announce'.trParams({
      'name': activePlayer.name.toUpperCase(),
    });

    isTurnTransition = true;
    turnTransitionMessage = 'turn_announce'.trParams({
      'name': activePlayer.name.toUpperCase(),
    });
    update();

    Future.delayed(const Duration(milliseconds: 1200), () {
      isTurnTransition = false;
      update();
      if (activePlayer.isBot) {
        Future.delayed(Duration(milliseconds: botSpeedMs), _botLogic);
      }
    });
  }

  void _addLog(String msg) {
    hitLogs.insert(0, msg);
    if (hitLogs.length > 30) hitLogs.removeLast();
  }

  void _endTurn() {
    pendingShots.clear();
    do {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    } while (players[currentPlayerIndex].isDefeated && !isGameOver);
    _startTurn();
  }

  void _botLogic() {
    if (isGameOver ||
        !players[currentPlayerIndex].isBot ||
        isTurnTransition ||
        isWaitingTurnEnd)
      return;

    int botId = players[currentPlayerIndex].id;
    List<PlayerData> validTargets = players
        .where((p) => p.id != botId && !p.isDefeated)
        .toList();
    var shootableTargets = validTargets
        .where((p) => canLockTarget(p.id))
        .toList();

    bool shotFired = false;
    if (shootableTargets.isNotEmpty) {
      shootableTargets.shuffle();
      for (var target in shootableTargets) {
        List<int> available = [];
        target.board.forEach((idx, cell) {
          if (!cell.isRevealed) available.add(idx);
        });

        if (available.isNotEmpty) {
          available.shuffle();
          _executeShoot(target.id, available.first);
          shotFired = true;
          break;
        }
      }
    }

    if (!shotFired) {
      remainingShotsInTurn = 0;
      if (!isGameOver) _endTurn();
      return;
    }

    if (remainingShotsInTurn > 0 && !isGameOver && !isWaitingTurnEnd) {
      Future.delayed(Duration(milliseconds: botSpeedMs), _botLogic);
    }
  }
}
