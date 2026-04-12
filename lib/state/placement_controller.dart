import 'dart:math';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/game_models.dart';
import 'game_controller.dart';

enum PlacementTool { land, turret, ship }

class PlacementController extends GetxController {
  final int columns = 8;
  final int rows = 6;
  int get gridSize => columns * rows;

  Map<int, Cell> board = {};
  List<ShipData> myShips = [];

  int enemyCount = 1;
  String playerName = "COMMANDER";

  PlacementTool currentTool = PlacementTool.land;

  final int maxLand = 12;
  final int maxTurrets = 3;

  List<int> unplacedShips = [4, 3, 2, 1, 1];
  int get placedShipsCount => 5 - unplacedShips.length;

  int selectedShipSize = 4;
  bool isHorizontal = true;
  int placedLand = 0;
  int placedTurrets = 0;

  String validationMessage = "";
  bool isBoardValid = false;

  @override
  void onInit() {
    super.onInit();
    _initEmptyBoard();
    if (Get.arguments != null) {
      enemyCount = Get.arguments['enemyCount'] ?? 1;
      playerName = Get.arguments['playerName'] ?? "COMMANDER";
    }
  }

  void _initEmptyBoard() {
    board = {for (var i = 0; i < gridSize; i++) i: Cell()};
    myShips.clear();
    unplacedShips = [4, 3, 2, 1, 1];
    placedLand = 0;
    placedTurrets = 0;
    selectedShipSize = 4;
    _validateBoard();
  }

  void setTool(PlacementTool tool) {
    currentTool = tool;
    HapticFeedback.lightImpact();
    update();
  }

  void toggleOrientation() {
    isHorizontal = !isHorizontal;
    HapticFeedback.lightImpact();
    update();
  }

  void selectShip(int size) {
    if (unplacedShips.contains(size)) {
      selectedShipSize = size;
      HapticFeedback.lightImpact();
      update();
    }
  }

  void clearAll() {
    HapticFeedback.mediumImpact();
    _initEmptyBoard();
    update();
  }

  void clearShips() {
    HapticFeedback.mediumImpact();
    board.forEach((key, cell) {
      if (cell.entity == Entity.ship) {
        cell.entity = Entity.none;
        cell.shipId = null;
      }
    });
    myShips.clear();
    unplacedShips = [4, 3, 2, 1, 1];
    selectedShipSize = 4;
    _validateBoard();
    update();
  }

  void autoDeploy() {
    HapticFeedback.heavyImpact();
    _initEmptyBoard();
    Random r = Random();
    List<List<int>> islandPatterns = [
      [0, 1, 2, 8, 9, 10, 5, 6, 13, 14, 21, 22],
      [32, 33, 34, 35, 40, 41, 42, 43, 44, 45, 46, 47],
      [0, 8, 16, 1, 9, 17, 2, 10, 18, 3, 11, 19],
      [6, 7, 14, 15, 22, 23, 30, 31, 38, 39, 46, 47],
    ];
    List<int> selectedLand = islandPatterns[r.nextInt(islandPatterns.length)];
    for (int idx in selectedLand) {
      board[idx]!.terrain = Terrain.land;
      placedLand++;
    }
    List<int> availableLand = List.from(selectedLand)..shuffle();
    for (int i = 0; i < maxTurrets; i++) {
      board[availableLand[i]]!.entity = Entity.turret;
      placedTurrets++;
    }
    List<int> fleet = [4, 3, 2, 1, 1];
    for (int size in fleet) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 100) {
        attempts++;
        bool isHoriz = r.nextBool();
        int startPos = r.nextInt(gridSize);
        int rr = startPos ~/ columns;
        int cc = startPos % columns;
        List<int> target = [];
        bool canPlace = true;
        for (int i = 0; i < size; i++) {
          if (isHoriz) {
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
            if (board[pos]!.terrain != Terrain.water ||
                board[pos]!.entity != Entity.none) {
              canPlace = false;
              break;
            }
          }
        }
        if (canPlace) {
          String newShipId =
              'ship_${DateTime.now().microsecondsSinceEpoch}_$size';
          myShips.add(ShipData(id: newShipId, size: size, positions: target));
          for (int pos in target) {
            board[pos]!.entity = Entity.ship;
            board[pos]!.shipId = newShipId;
          }
          placed = true;
        }
      }
    }
    unplacedShips.clear();
    _validateBoard();
    update();
  }

  void handleTap(int index) {
    Cell cell = board[index]!;
    bool actionSuccess = false;
    if (currentTool == PlacementTool.land) {
      if (cell.terrain == Terrain.water &&
          placedLand < maxLand &&
          cell.entity == Entity.none) {
        cell.terrain = Terrain.land;
        placedLand++;
        actionSuccess = true;
      } else if (cell.terrain == Terrain.land) {
        if (cell.entity == Entity.turret) placedTurrets--;
        cell.entity = Entity.none;
        cell.terrain = Terrain.water;
        placedLand--;
        actionSuccess = true;
      }
    } else if (currentTool == PlacementTool.turret) {
      if (cell.terrain == Terrain.land) {
        if (cell.entity == Entity.none && placedTurrets < maxTurrets) {
          cell.entity = Entity.turret;
          placedTurrets++;
          actionSuccess = true;
        } else if (cell.entity == Entity.turret) {
          cell.entity = Entity.none;
          placedTurrets--;
          actionSuccess = true;
        }
      }
    } else if (currentTool == PlacementTool.ship) {
      actionSuccess = _placeShipLogic(index);
    }
    if (actionSuccess) HapticFeedback.lightImpact();
    _validateBoard();
    update();
  }

  bool _placeShipLogic(int index) {
    if (!unplacedShips.contains(selectedShipSize)) return false;
    List<int> targetCells = [];
    int r = index ~/ columns;
    int c = index % columns;
    for (int i = 0; i < selectedShipSize; i++) {
      if (isHorizontal) {
        if (c + i >= columns) return false;
        targetCells.add(r * columns + (c + i));
      } else {
        if (r + i >= rows) return false;
        targetCells.add((r + i) * columns + c);
      }
    }
    for (int pos in targetCells) {
      if (board[pos]!.terrain != Terrain.water ||
          board[pos]!.entity != Entity.none)
        return false;
    }
    String newShipId = 'ship_${DateTime.now().millisecondsSinceEpoch}';
    myShips.add(
      ShipData(id: newShipId, size: selectedShipSize, positions: targetCells),
    );
    for (int pos in targetCells) {
      board[pos]!.entity = Entity.ship;
      board[pos]!.shipId = newShipId;
    }
    unplacedShips.remove(selectedShipSize);
    if (unplacedShips.isNotEmpty) selectedShipSize = unplacedShips.first;
    return true;
  }

  void _validateBoard() {
    if (placedLand != maxLand) {
      validationMessage = 'req_land'.trParams({
        'count': (maxLand - placedLand).toString(),
      });
      isBoardValid = false;
      return;
    }
    if (placedTurrets != maxTurrets) {
      validationMessage = 'req_turret'.trParams({
        'count': (maxTurrets - placedTurrets).toString(),
      });
      isBoardValid = false;
      return;
    }
    if (unplacedShips.isNotEmpty) {
      validationMessage = 'req_ship'.tr;
      isBoardValid = false;
      return;
    }
    if (!_checkIslandCount()) {
      validationMessage = 'req_island'.tr;
      isBoardValid = false;
      return;
    }
    validationMessage = 'all_ready'.tr;
    isBoardValid = true;
  }

  bool _checkIslandCount() {
    List<int> landIndexes = [];
    board.forEach((idx, cell) {
      if (cell.terrain == Terrain.land) landIndexes.add(idx);
    });
    List<int> unvisited = List.from(landIndexes);
    int islandCount = 0;
    while (unvisited.isNotEmpty) {
      islandCount++;
      if (islandCount > 2) return false;
      List<int> queue = [unvisited.first];
      unvisited.remove(unvisited.first);
      while (queue.isNotEmpty) {
        int current = queue.removeAt(0);
        List<int> neighbors = [];
        if (current >= columns) neighbors.add(current - columns);
        if (current < gridSize - columns) neighbors.add(current + columns);
        if (current % columns != 0) neighbors.add(current - 1);
        if (current % columns != columns - 1) neighbors.add(current + 1);
        for (int n in neighbors) {
          if (unvisited.contains(n)) {
            queue.add(n);
            unvisited.remove(n);
          }
        }
      }
    }
    return true;
  }

  void confirmPlacement() {
    if (isBoardValid) {
      HapticFeedback.heavyImpact();
      final gameCtrl = Get.find<GameController>();
      gameCtrl.startGame(board, myShips, enemyCount, playerName);
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.offAllNamed('/game');
      });
    }
  }
}
