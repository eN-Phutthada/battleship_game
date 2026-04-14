import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/game_models.dart';
import '../state/sound_controller.dart';

enum BotSpeed { slow, normal, fast }

enum BotDifficulty { easy, normal, hard }

enum AssistLevel { casual, standard, hardcore, realLife }

class GameController extends GetxController {
  // --- Grid Config ---
  int columns = 8;
  int rows = 6;
  int get gridSize => columns * rows;

  // --- Game State ---
  List<PlayerData> players = [];
  int currentPlayerIndex = 0;
  bool isGameOver = false;
  bool isDeploying = false;

  // --- Combat State ---
  Map<int, int> turnShotsFiredAt = {};
  int remainingShotsInTurn = 0;
  List<Map<String, int>> pendingShots = [];
  Map<String, dynamic>? activeShotAnimation;
  Map<String, String> manualMarkers = {};

  // --- UI State ---
  String statusMessage = "";
  List<String> hitLogs = [];
  int selectedTargetId = 1;
  bool isTurnTransition = false;
  bool isWaitingTurnEnd = false;
  String turnTransitionMessage = "";

  // --- Game Settings ---
  bool isDevMode = false;
  bool isAutoTrack = true;
  BotSpeed currentBotSpeed = BotSpeed.normal;
  BotDifficulty botDifficulty = BotDifficulty.normal;
  AssistLevel assistLevel = AssistLevel.standard;

  // --- Calculated Properties ---
  int get botSpeedMs => currentBotSpeed == BotSpeed.slow
      ? 1500
      : (currentBotSpeed == BotSpeed.fast ? 400 : 1000);

  // INITIALIZATION & SETUP
  void startGame(int cols, int rws, Map<int, Cell> humanBoard,
      List<ShipData> humanShips, int enemyCount, String pName) {
    columns = cols;
    rows = rws;

    players.clear();
    hitLogs.clear();
    isGameOver = false;
    isDeploying = true;
    isWaitingTurnEnd = false;
    statusMessage = 'simulating'.tr;
    pendingShots.clear();
    currentBotSpeed = BotSpeed.normal;
    isAutoTrack = true;
    manualMarkers.clear();

    if (Get.isRegistered<SoundController>()) {
      Get.find<SoundController>().playBGM();
    }

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

  Map<int, Cell> _cloneBoard(Map<int, Cell> source) {
    return source.map((key, value) => MapEntry(
        key,
        Cell(
            terrain: value.terrain,
            entity: value.entity,
            isRevealed: value.isRevealed,
            shipId: value.shipId)));
  }

  // BOT LOGIC & GENERATION
  void _generateBotBoard(PlayerData bot) {
    Random r = Random();
    int maxLand = (gridSize * 0.25).floor();
    int maxTurrets = (maxLand / 4).ceil();
    List<int> fleetDefinition = gridSize <= 48
        ? [4, 3, 2, 1, 1]
        : (gridSize <= 80 ? [5, 4, 3, 3, 2, 2] : [5, 4, 4, 3, 3, 2, 2, 1, 1]);

    int maxBoardAttempts = 50;
    bool deploymentSuccess = false;

    for (int attempt = 0; attempt < maxBoardAttempts; attempt++) {
      bot.board = {for (var i = 0; i < gridSize; i++) i: Cell()};
      bot.ships.clear();

      int totalLandNeeded = maxLand;
      int numIslands = r.nextBool() ? 1 : 2;
      List<int> allPlacedLand = [];

      for (int island = 0; island < numIslands; island++) {
        int sizeToBuild = (island == 0 && numIslands == 2)
            ? r.nextInt(totalLandNeeded ~/ 2) + 3
            : totalLandNeeded;
        totalLandNeeded -= sizeToBuild;

        int seed;
        do {
          seed = r.nextInt(gridSize);
        } while (bot.board[seed]!.terrain == Terrain.land);

        List<int> islandGroup = [seed];
        bot.board[seed]!.terrain = Terrain.land;
        allPlacedLand.add(seed);

        int failsafe = 0;
        while (islandGroup.length < sizeToBuild && failsafe < 50) {
          int basePos = islandGroup[r.nextInt(islandGroup.length)];
          int row = basePos ~/ columns;
          int col = basePos % columns;
          List<int> neighbors = [];
          if (row > 0 &&
              bot.board[basePos - columns]!.terrain == Terrain.water) {
            neighbors.add(basePos - columns);
          }
          if (row < rows - 1 &&
              bot.board[basePos + columns]!.terrain == Terrain.water) {
            neighbors.add(basePos + columns);
          }
          if (col > 0 && bot.board[basePos - 1]!.terrain == Terrain.water) {
            neighbors.add(basePos - 1);
          }
          if (col < columns - 1 &&
              bot.board[basePos + 1]!.terrain == Terrain.water) {
            neighbors.add(basePos + 1);
          }

          if (neighbors.isEmpty) {
            failsafe++;
          } else {
            int nextPos = neighbors[r.nextInt(neighbors.length)];
            bot.board[nextPos]!.terrain = Terrain.land;
            islandGroup.add(nextPos);
            allPlacedLand.add(nextPos);
            failsafe = 0;
          }
        }
      }

      int expandAttempts = 0;
      while (allPlacedLand.length < maxLand && expandAttempts < 200) {
        int basePos = allPlacedLand[r.nextInt(allPlacedLand.length)];
        int row = basePos ~/ columns;
        int col = basePos % columns;
        List<int> neighbors = [];
        if (row > 0 && bot.board[basePos - columns]!.terrain == Terrain.water) {
          neighbors.add(basePos - columns);
        }
        if (row < rows - 1 &&
            bot.board[basePos + columns]!.terrain == Terrain.water) {
          neighbors.add(basePos + columns);
        }
        if (col > 0 && bot.board[basePos - 1]!.terrain == Terrain.water) {
          neighbors.add(basePos - 1);
        }
        if (col < columns - 1 &&
            bot.board[basePos + 1]!.terrain == Terrain.water) {
          neighbors.add(basePos + 1);
        }

        if (neighbors.isNotEmpty) {
          int nextPos = neighbors[r.nextInt(neighbors.length)];
          bot.board[nextPos]!.terrain = Terrain.land;
          allPlacedLand.add(nextPos);
        } else {
          expandAttempts++;
        }
      }

      if (allPlacedLand.length < maxLand) continue;

      allPlacedLand.shuffle(r);
      for (int i = 0; i < maxTurrets; i++) {
        bot.board[allPlacedLand[i]]!.entity = Entity.turret;
      }

      bool shipsPlaced = true;
      for (int size in fleetDefinition) {
        if (!_autoPlaceBotShip(bot, size, r)) {
          shipsPlaced = false;
          break;
        }
      }

      if (shipsPlaced) {
        deploymentSuccess = true;
        break;
      }
    }

    if (!deploymentSuccess) {
      bot.board = {for (var i = 0; i < gridSize; i++) i: Cell()};
      for (int size in fleetDefinition) {
        _autoPlaceBotShip(bot, size, r);
      }
    }
  }

  bool _autoPlaceBotShip(PlayerData bot, int size, Random r) {
    List<Map<String, dynamic>> validSpots = [];

    for (int pos = 0; pos < gridSize; pos++) {
      for (bool horiz in [true, false]) {
        List<int> targetCells = _calculateBotShipOccupancy(pos, size, horiz);
        if (targetCells.isNotEmpty) {
          bool canPlace = true;
          for (int cell in targetCells) {
            if (bot.board[cell]!.terrain != Terrain.water ||
                bot.board[cell]!.entity != Entity.none) {
              canPlace = false;
              break;
            }
          }
          if (canPlace) {
            validSpots.add({'pos': pos, 'horiz': horiz, 'cells': targetCells});
          }
        }
      }
    }

    if (validSpots.isEmpty) return false;

    var spot = validSpots[r.nextInt(validSpots.length)];
    String newShipId =
        'bot_${bot.id}_ship_${DateTime.now().microsecondsSinceEpoch}_$size';
    bot.ships
        .add(ShipData(id: newShipId, size: size, positions: spot['cells']));

    for (int pos in spot['cells']) {
      bot.board[pos]!.entity = Entity.ship;
      bot.board[pos]!.shipId = newShipId;
    }
    return true;
  }

  List<int> _calculateBotShipOccupancy(int index, int size, bool isHoriz) {
    List<int> cells = [];
    int r = index ~/ columns;
    int c = index % columns;

    for (int i = 0; i < size; i++) {
      int nextR = isHoriz ? r : r + i;
      int nextC = isHoriz ? c + i : c;
      if (nextR >= rows || nextC >= columns) return [];
      cells.add(nextR * columns + nextC);
    }
    return cells;
  }

  void _botLogic() {
    if (isGameOver ||
        !players[currentPlayerIndex].isBot ||
        isTurnTransition ||
        isWaitingTurnEnd) {
      return;
    }

    int botId = players[currentPlayerIndex].id;
    List<PlayerData> validTargets =
        players.where((p) => p.id != botId && !p.isDefeated).toList();
    var shootableTargets =
        validTargets.where((p) => canLockTarget(p.id)).toList();

    bool shotFired = false;
    if (shootableTargets.isNotEmpty) {
      shootableTargets.shuffle();
      for (var target in shootableTargets) {
        List<int> available = [];

        if (botDifficulty == BotDifficulty.hard) {
          for (int i = 0; i < gridSize; i++) {
            if (target.board[i]!.isRevealed &&
                target.board[i]!.entity == Entity.ship) {
              ShipData ship = target.ships
                  .firstWhere((s) => s.id == target.board[i]!.shipId);
              if (!ship.isSunk) {
                int r = i ~/ columns;
                int c = i % columns;
                if (r > 0 && !target.board[i - columns]!.isRevealed) {
                  available.add(i - columns);
                }
                if (r < rows - 1 && !target.board[i + columns]!.isRevealed) {
                  available.add(i + columns);
                }
                if (c > 0 && !target.board[i - 1]!.isRevealed) {
                  available.add(i - 1);
                }
                if (c < columns - 1 && !target.board[i + 1]!.isRevealed) {
                  available.add(i + 1);
                }
              }
            }
          }
        }
        if (available.isEmpty && botDifficulty != BotDifficulty.easy) {
          target.board.forEach((idx, cell) {
            if (!cell.isRevealed) available.add(idx);
          });
        }
        if (botDifficulty == BotDifficulty.easy) {
          available = List.generate(gridSize, (i) => i);
        }

        if (available.isNotEmpty) {
          available.shuffle();
          if (Get.isRegistered<SoundController>()) {
            Get.find<SoundController>().playFire();
          }
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

  // COMBAT LOGIC
  void _startTurn() {
    if (isGameOver) return;
    pendingShots.clear();
    isWaitingTurnEnd = false;
    var activePlayer = players[currentPlayerIndex];

    if (activePlayer.isBot) {
      selectedTargetId = 0;
    } else {
      if (selectedTargetId == 0 ||
          players
              .firstWhere((p) => p.id == selectedTargetId,
                  orElse: () => players[1])
              .isDefeated) {
        var aliveEnemies = players.where((p) => p.isBot && !p.isDefeated);
        if (aliveEnemies.isNotEmpty) {
          selectedTargetId = aliveEnemies.first.id;
        } else {
          selectedTargetId = 0;
        }
      }
    }

    remainingShotsInTurn = activePlayer.currentAmmo;
    activePlayer.bonusAmmo = 0;
    turnShotsFiredAt.clear();
    statusMessage =
        'turn_announce'.trParams({'name': activePlayer.name.toUpperCase()});
    isTurnTransition = true;
    turnTransitionMessage =
        'turn_announce'.trParams({'name': activePlayer.name.toUpperCase()});
    update();

    Future.delayed(const Duration(milliseconds: 1200), () {
      isTurnTransition = false;
      update();
      if (activePlayer.isBot) {
        Future.delayed(Duration(milliseconds: botSpeedMs), _botLogic);
      }
    });
  }

  void _endTurn() {
    pendingShots.clear();
    do {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    } while (players[currentPlayerIndex].isDefeated && !isGameOver);
    _startTurn();
  }

  bool canLockTarget(int targetPlayerId) {
    if (targetPlayerId == players[currentPlayerIndex].id) return false;
    if (players.firstWhere((p) => p.id == targetPlayerId).isDefeated) {
      return false;
    }
    int simulatedShotsThisTarget = (turnShotsFiredAt[targetPlayerId] ?? 0) +
        pendingShots.where((s) => s['targetId'] == targetPlayerId).length;
    int minShotsAtAnyTarget = 999;
    for (var p in players) {
      if (p.id != players[currentPlayerIndex].id && !p.isDefeated) {
        int s = (turnShotsFiredAt[p.id] ?? 0) +
            pendingShots.where((shot) => shot['targetId'] == p.id).length;
        if (s < minShotsAtAnyTarget) minShotsAtAnyTarget = s;
      }
    }
    return simulatedShotsThisTarget == minShotsAtAnyTarget;
  }

  void confirmFire() async {
    if (pendingShots.isEmpty || isWaitingTurnEnd) return;
    List<Map<String, int>> shotsToFire = List.from(pendingShots);
    pendingShots.clear();
    update();
    for (var shot in shotsToFire) {
      if (Get.isRegistered<SoundController>()) {
        Get.find<SoundController>().playFire();
      }
      _executeShoot(shot['targetId']!, shot['cellIndex']!);
      await Future.delayed(Duration(milliseconds: botSpeedMs ~/ 2));
    }
  }

  void _executeShoot(int targetPlayerId, int cellIndex) {
    if (remainingShotsInTurn <= 0 || isGameOver) return;

    var targetPlayer = players.firstWhere((p) => p.id == targetPlayerId);
    var cell = targetPlayer.board[cellIndex]!;
    bool wasRevealed = cell.isRevealed;

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

    activeShotAnimation = {
      'targetId': targetPlayerId,
      'index': cellIndex,
      'isHit': isHit,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
    update();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (Get.isRegistered<SoundController>()) {
        if (wasRevealed && assistLevel != AssistLevel.realLife) {
          Get.find<SoundController>().playError();
        } else if (isHit) {
          Get.find<SoundController>().playHit();
        } else {
          Get.find<SoundController>().playMiss();
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (activeShotAnimation != null &&
          activeShotAnimation!['index'] == cellIndex) {
        activeShotAnimation = null;
        update();
      }
    });

    String coord =
        "${String.fromCharCode(65 + (cellIndex ~/ columns))}${cellIndex % columns + 1}";

    if (cell.terrain == Terrain.land && cell.entity == Entity.none) {
      targetPlayer.bonusAmmo++;
    }

    bool isShipSunk = false;
    ShipData? hitShip;
    if (cell.entity == Entity.ship) {
      hitShip = targetPlayer.ships.firstWhere((s) => s.id == cell.shipId);
      isShipSunk =
          hitShip.positions.every((pos) => targetPlayer.board[pos]!.isRevealed);
      if (isShipSunk) hitShip.isSunk = true;
    }

    if (assistLevel == AssistLevel.realLife) {
      HapticFeedback.heavyImpact();
      String shooterDisplay = isShooterMe ? 'you_tag'.tr : shooterName;

      if (cell.terrain == Terrain.land && cell.entity == Entity.none) {
        _addLog('log_reallife_land'
            .trParams({'shooter': shooterDisplay, 'coord': coord}));
      } else if (isShipSunk) {
        _addLog('log_reallife_sunk'
            .trParams({'shooter': shooterDisplay, 'coord': coord}));
      } else if (isHit) {
        _addLog('log_reallife_hit'
            .trParams({'shooter': shooterDisplay, 'coord': coord}));
      } else {
        _addLog('log_reallife_miss'
            .trParams({'shooter': shooterDisplay, 'coord': coord}));
      }
    } else {
      if (wasRevealed) {
        HapticFeedback.lightImpact();
        if (isShooterMe) {
          _addLog('wasted_shot'.tr);
        } else {
          _addLog('wasted_shot_bot'.trParams({'shooter': shooterName}));
        }
      } else {
        if (assistLevel == AssistLevel.hardcore) {
          HapticFeedback.heavyImpact();
          if (isHit) {
            _addLog('log_hardcore_hit'.trParams({'target': targetName}));
          } else {
            _addLog('log_hardcore_miss'.trParams({'target': targetName}));
          }
        } else {
          if (cell.entity == Entity.ship) {
            HapticFeedback.heavyImpact();
            if (isShipSunk) {
              if (isShooterMe) {
                _addLog('log_sunk_me'.trParams(
                    {'target': targetName, 'size': hitShip!.size.toString()}));
              } else {
                _addLog(isTargetMe
                    ? 'log_sunk_you'.trParams({'shooter': shooterName})
                    : 'log_sunk_enemy'.trParams(
                        {'shooter': shooterName, 'target': targetName}));
              }
            } else {
              if (isShooterMe) {
                _addLog('log_hit_me'.trParams({'target': targetName}));
              } else {
                _addLog(isTargetMe
                    ? 'log_hit_you'.trParams({'shooter': shooterName})
                    : 'log_hit_enemy'.trParams(
                        {'shooter': shooterName, 'target': targetName}));
              }
            }
          } else if (cell.entity == Entity.turret) {
            HapticFeedback.mediumImpact();
            if (isShooterMe) {
              _addLog('log_turret_me'.trParams({'target': targetName}));
            } else {
              _addLog(isTargetMe
                  ? 'log_turret_you'.trParams({'shooter': shooterName})
                  : 'log_turret_enemy'.trParams(
                      {'shooter': shooterName, 'target': targetName}));
            }
          } else {
            HapticFeedback.lightImpact();
          }
        }
      }
    }

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
      String winner =
          activePlayers.isNotEmpty ? activePlayers.first.name : "NOBODY";
      HapticFeedback.vibrate();

      if (Get.isRegistered<SoundController>()) {
        Get.find<SoundController>().stopBGM();
        if (activePlayers.isNotEmpty && activePlayers.first.id == 0) {
          Get.find<SoundController>().playWin();
        } else {
          Get.find<SoundController>().playLose();
        }
      }

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
                    BoxShadow(color: Colors.black26, offset: Offset(6, 6))
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      activePlayers.isNotEmpty && activePlayers.first.id == 0
                          ? Icons.emoji_events
                          : Icons.sentiment_very_dissatisfied,
                      size: 48,
                      color: const Color(0xFFD32F2F)),
                  const SizedBox(height: 8),
                  Text('war_over'.tr,
                      style: const TextStyle(
                          color: Color(0xFF000080),
                          fontWeight: FontWeight.w900,
                          fontSize: 24)),
                  const Divider(color: Color(0xFF000080), thickness: 2),
                  const SizedBox(height: 8),
                  Text('wins'.trParams({'name': winner}),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF000080),
                          shape: const RoundedRectangleBorder()),
                      onPressed: () {
                        if (Get.isRegistered<SoundController>()) {
                          Get.find<SoundController>().stopBGM();
                        }
                        Get.back();
                        Get.offAllNamed('/');
                      },
                      child: Text('return_base'.tr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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

  // UI ACTIONS
  void selectTarget(int botId) {
    selectedTargetId = botId;
    update();
  }

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

  void toggleLockTarget(int targetPlayerId, int cellIndex) {
    if (players[currentPlayerIndex].isBot ||
        isGameOver ||
        isTurnTransition ||
        isWaitingTurnEnd) {
      return;
    }

    int existingIndex = pendingShots.indexWhere(
        (s) => s['targetId'] == targetPlayerId && s['cellIndex'] == cellIndex);
    if (existingIndex != -1) {
      pendingShots.removeAt(existingIndex);
      HapticFeedback.lightImpact();
      if (Get.isRegistered<SoundController>()) {
        Get.find<SoundController>().playClick();
      }
      update();
      return;
    }
    if (pendingShots.length >= remainingShotsInTurn) return;

    bool isRevealed = players
        .firstWhere((p) => p.id == targetPlayerId)
        .board[cellIndex]!
        .isRevealed;

    if (isRevealed) {
      if (assistLevel == AssistLevel.casual) {
        HapticFeedback.vibrate();
        if (Get.isRegistered<SoundController>()) {
          Get.find<SoundController>().playError();
        }
        Get.snackbar('attention'.tr, 'casual_block'.tr,
            backgroundColor: const Color(0xFFFDFBF7),
            colorText: const Color(0xFFD32F2F),
            borderColor: const Color(0xFFD32F2F),
            borderWidth: 2,
            borderRadius: 6,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            icon: const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFD32F2F), size: 26),
            snackPosition: SnackPosition.TOP,
            boxShadows: [
              const BoxShadow(color: Colors.black26, offset: Offset(2, 2))
            ],
            duration: const Duration(seconds: 2));
        return;
      }
    }

    if (!canLockTarget(targetPlayerId)) {
      HapticFeedback.vibrate();
      if (Get.isRegistered<SoundController>()) {
        Get.find<SoundController>().playError();
      }
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
      Get.snackbar('attention'.tr, 'distribute_shots'.tr,
          backgroundColor: const Color(0xFFFDFBF7),
          colorText: const Color(0xFFD32F2F),
          borderColor: const Color(0xFFD32F2F),
          borderWidth: 2,
          borderRadius: 6,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          icon: const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFD32F2F), size: 26),
          snackPosition: SnackPosition.TOP,
          boxShadows: [
            const BoxShadow(color: Colors.black26, offset: Offset(2, 2))
          ],
          duration: const Duration(seconds: 2));
      return;
    }

    HapticFeedback.lightImpact();
    if (Get.isRegistered<SoundController>()) {
      Get.find<SoundController>().playLock();
    }
    pendingShots.add({'targetId': targetPlayerId, 'cellIndex': cellIndex});
    update();
  }

  void cancelAllLocks() {
    pendingShots.clear();
    HapticFeedback.lightImpact();
    if (Get.isRegistered<SoundController>()) {
      Get.find<SoundController>().playClick();
    }
    update();
  }

  void toggleManualMarker(int targetPlayerId, int cellIndex) {
    if (assistLevel != AssistLevel.realLife) return;

    HapticFeedback.selectionClick();
    String key = "${targetPlayerId}_$cellIndex";

    if (!manualMarkers.containsKey(key)) {
      manualMarkers[key] = 'X';
    } else if (manualMarkers[key] == 'X') {
      manualMarkers[key] = 'O';
    } else {
      manualMarkers.remove(key);
    }
    update();
  }

  // UTILS
  void _addLog(String msg) {
    hitLogs.insert(0, msg);
    if (hitLogs.length > 30) hitLogs.removeLast();
  }
}
