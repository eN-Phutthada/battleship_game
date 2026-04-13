import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/game_models.dart';
import 'game_controller.dart';

enum PlacementTool { land, turret, ship }

class PlacementController extends GetxController {
  // --- Grid Config ---
  int columns = 8;
  int rows = 6;
  int get gridSize => columns * rows;

  // --- Game State ---
  Map<int, Cell> board = {};
  List<ShipData> myShips = [];
  List<int> unplacedShips = [];

  // --- Resources (Calculated) ---
  int maxLand = 12;
  int maxTurrets = 3;
  List<int> fleetDefinition = [4, 3, 2, 1, 1];

  // --- UI State ---
  int enemyCount = 1;
  String playerName = "COMMANDER";
  PlacementTool currentTool = PlacementTool.land;
  int selectedShipSize = 4;
  bool isHorizontal = true;
  int placedLand = 0;
  int placedTurrets = 0;

  String validationMessage = "";
  bool isBoardValid = false;

  int get placedShipsCount => fleetDefinition.length - unplacedShips.length;

  @override
  void onInit() {
    super.onInit();
    _setupGridConfigs();
    _initEmptyBoard();
  }

  void _setupGridConfigs() {
    if (Get.arguments != null) {
      columns = Get.arguments['columns'] ?? 8;
      rows = Get.arguments['rows'] ?? 6;
      enemyCount = Get.arguments['enemyCount'] ?? 1;
      playerName = Get.arguments['playerName'] ?? "COMMANDER";
    }

    maxLand = (gridSize * 0.25).floor();
    maxTurrets = (maxLand / 4).ceil();

    if (gridSize <= 48) {
      fleetDefinition = [4, 3, 2, 1, 1];
    } else if (gridSize <= 80) {
      fleetDefinition = [5, 4, 3, 3, 2, 2];
    } else {
      fleetDefinition = [5, 4, 4, 3, 3, 2, 2, 1, 1];
    }
  }

  void _initEmptyBoard() {
    board = {for (var i = 0; i < gridSize; i++) i: Cell()};
    myShips.clear();
    unplacedShips = List.from(fleetDefinition);
    placedLand = 0;
    placedTurrets = 0;
    selectedShipSize = unplacedShips.isNotEmpty ? unplacedShips.first : 0;
    _validateBoard();
  }

  // --- UI Actions ---

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
    unplacedShips = List.from(fleetDefinition);
    selectedShipSize = unplacedShips.isNotEmpty ? unplacedShips.first : 0;
    _validateBoard();
    update();
  }

  // --- Placement Logic ---

  void handleTap(int index) {
    switch (currentTool) {
      case PlacementTool.land:
        _toggleLand(index);
        break;
      case PlacementTool.turret:
        _toggleTurret(index);
        break;
      case PlacementTool.ship:
        _placeShipLogic(index);
        break;
    }
    _validateBoard();
    update();
  }

  void _showError(String message) {
    HapticFeedback.vibrate();
    Get.snackbar(
      'attention'.tr,
      message,
      backgroundColor: const Color(0xFFFDFBF7),
      colorText: const Color(0xFFD32F2F),
      borderColor: const Color(0xFFD32F2F),
      borderWidth: 2,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.info_outline, color: Color(0xFFD32F2F), size: 28),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      boxShadows: [
        const BoxShadow(color: Colors.black26, offset: Offset(4, 4))
      ],
    );
  }

  void _toggleLand(int index) {
    Cell cell = board[index]!;
    if (cell.terrain == Terrain.water && cell.entity == Entity.none) {
      if (placedLand < maxLand) {
        cell.terrain = Terrain.land;
        placedLand++;
        HapticFeedback.lightImpact();
      } else {
        _showError('err_max_land'.tr);
      }
    } else if (cell.terrain == Terrain.land) {
      if (cell.entity == Entity.turret) placedTurrets--;
      cell.entity = Entity.none;
      cell.terrain = Terrain.water;
      placedLand--;
      HapticFeedback.lightImpact();
    } else if (cell.entity == Entity.ship) {
      _showError('err_land_on_ship'.tr);
    }
  }

  void _toggleTurret(int index) {
    Cell cell = board[index]!;
    if (cell.terrain != Terrain.land) {
      _showError('err_turret_on_water'.tr);
      return;
    }

    if (cell.entity == Entity.none) {
      if (placedTurrets < maxTurrets) {
        cell.entity = Entity.turret;
        placedTurrets++;
        HapticFeedback.lightImpact();
      } else {
        _showError('err_max_turret'.tr);
      }
    } else if (cell.entity == Entity.turret) {
      cell.entity = Entity.none;
      placedTurrets--;
      HapticFeedback.lightImpact();
    }
  }

  bool _placeShipLogic(int index, {bool isAuto = false}) {
    if (!isAuto && board[index]!.entity == Entity.ship) {
      _removeShip(board[index]!.shipId!);
      return true;
    }

    if (!unplacedShips.contains(selectedShipSize)) return false;

    List<int> targetCells = _calculateShipOccupancy(index, selectedShipSize);
    if (targetCells.isEmpty) {
      if (!isAuto) _showError('err_ship_out_of_bounds'.tr);
      return false;
    }

    for (int pos in targetCells) {
      if (board[pos]!.terrain != Terrain.water) {
        if (!isAuto) _showError('err_ship_on_land'.tr);
        return false;
      }
      if (board[pos]!.entity == Entity.ship) {
        if (!isAuto) _showError('err_ship_overlap'.tr);
        return false;
      }
    }

    final newShipId = 'ship_${DateTime.now().microsecondsSinceEpoch}';
    myShips.add(ShipData(
        id: newShipId, size: selectedShipSize, positions: targetCells));

    for (int pos in targetCells) {
      board[pos]!.entity = Entity.ship;
      board[pos]!.shipId = newShipId;
    }

    unplacedShips.remove(selectedShipSize);
    if (unplacedShips.isNotEmpty) selectedShipSize = unplacedShips.first;

    if (!isAuto) HapticFeedback.lightImpact();
    return true;
  }

  void _removeShip(String shipId) {
    ShipData? shipToRemove;
    try {
      shipToRemove = myShips.firstWhere((s) => s.id == shipId);
    } catch (e) {
      return;
    }

    for (int pos in shipToRemove.positions) {
      board[pos]!.entity = Entity.none;
      board[pos]!.shipId = null;
    }

    myShips.remove(shipToRemove);
    unplacedShips.add(shipToRemove.size);
    unplacedShips.sort((a, b) => b.compareTo(a));
    selectedShipSize = unplacedShips.first;
  }

  List<int> _calculateShipOccupancy(int index, int size) {
    List<int> cells = [];
    int r = index ~/ columns;
    int c = index % columns;

    for (int i = 0; i < size; i++) {
      int nextR = isHorizontal ? r : r + i;
      int nextC = isHorizontal ? c + i : c;

      if (nextR >= rows || nextC >= columns) return [];
      cells.add(nextR * columns + nextC);
    }
    return cells;
  }

  // --- Validation Logic ---

  void _validateBoard() {
    if (placedLand != maxLand) {
      validationMessage =
          'req_land'.trParams({'count': (maxLand - placedLand).toString()});
      isBoardValid = false;
    } else if (placedTurrets != maxTurrets) {
      validationMessage = 'req_turret'
          .trParams({'count': (maxTurrets - placedTurrets).toString()});
      isBoardValid = false;
    } else if (unplacedShips.isNotEmpty) {
      validationMessage = 'req_ship'.tr;
      isBoardValid = false;
    } else if (!_checkIslandCount()) {
      validationMessage = 'req_island'.tr;
      isBoardValid = false;
    } else {
      validationMessage = 'all_ready'.tr;
      isBoardValid = true;
    }
  }

  bool _checkIslandCount() {
    List<int> landIndexes = board.entries
        .where((e) => e.value.terrain == Terrain.land)
        .map((e) => e.key)
        .toList();
    if (landIndexes.isEmpty) return true;

    List<int> unvisited = List.from(landIndexes);
    int islandCount = 0;

    while (unvisited.isNotEmpty) {
      islandCount++;
      if (islandCount > 2) return false;

      List<int> queue = [unvisited.first];
      unvisited.remove(unvisited.first);

      while (queue.isNotEmpty) {
        int current = queue.removeAt(0);
        int r = current ~/ columns;
        int c = current % columns;

        List<int> potentialNeighbors = [];
        if (r > 0) potentialNeighbors.add(current - columns);
        if (r < rows - 1) potentialNeighbors.add(current + columns);
        if (c > 0) potentialNeighbors.add(current - 1);
        if (c < columns - 1) potentialNeighbors.add(current + 1);

        for (int neighbor in potentialNeighbors) {
          if (unvisited.contains(neighbor)) {
            queue.add(neighbor);
            unvisited.remove(neighbor);
          }
        }
      }
    }
    return true;
  }

  // --- Auto Deploy (Procedural) ---

  void autoDeploy() {
    HapticFeedback.heavyImpact();
    Random r = Random();
    int maxBoardAttempts = 50;
    bool deploymentSuccess = false;

    for (int attempt = 0; attempt < maxBoardAttempts; attempt++) {
      _initEmptyBoard();

      int totalLandNeeded = maxLand;
      int numIslands = r.nextBool() ? 1 : 2;
      List<int> allPlacedLand = [];

      for (int island = 0; island < numIslands; island++) {
        int sizeToBuild = (island == 0 && numIslands == 2)
            ? r.nextInt(totalLandNeeded ~/ 2) + 3
            : totalLandNeeded;
        totalLandNeeded -= sizeToBuild;
        _generateSingleIsland(sizeToBuild, allPlacedLand, r);
      }

      int expandAttempts = 0;
      while (allPlacedLand.length < maxLand && expandAttempts < 200) {
        if (!_expandLand(allPlacedLand, r)) expandAttempts++;
      }

      if (allPlacedLand.length < maxLand) continue;
      placedLand = maxLand;

      List<int> landPool = List.from(allPlacedLand)..shuffle(r);
      for (int i = 0; i < maxTurrets; i++) {
        board[landPool[i]]!.entity = Entity.turret;
        placedTurrets++;
      }

      bool shipsPlaced = true;
      for (int size in List.from(unplacedShips)) {
        selectedShipSize = size;
        if (!_autoPlaceShip(size, r)) {
          shipsPlaced = false;
          break;
        }
      }

      if (shipsPlaced && _checkIslandCount()) {
        deploymentSuccess = true;
        break;
      }
    }

    if (!deploymentSuccess) {
      _initEmptyBoard();
      Get.snackbar(
        'Auto Deploy Failed',
        'Area is too tight! Retrying...',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    _validateBoard();
    update();
  }

  bool _autoPlaceShip(int size, Random r) {
    List<Map<String, dynamic>> validSpots = [];

    for (int pos = 0; pos < gridSize; pos++) {
      for (bool horiz in [true, false]) {
        isHorizontal = horiz;
        List<int> targetCells = _calculateShipOccupancy(pos, size);
        if (targetCells.isNotEmpty) {
          bool canPlace = true;
          for (int cell in targetCells) {
            if (board[cell]!.terrain != Terrain.water ||
                board[cell]!.entity != Entity.none) {
              canPlace = false;
              break;
            }
          }
          if (canPlace) validSpots.add({'pos': pos, 'horiz': horiz});
        }
      }
    }

    if (validSpots.isEmpty) return false;

    var spot = validSpots[r.nextInt(validSpots.length)];
    isHorizontal = spot['horiz'];
    _placeShipLogic(spot['pos'], isAuto: true);
    return true;
  }

  void _generateSingleIsland(int size, List<int> masterList, Random r) {
    int seed;
    do {
      seed = r.nextInt(gridSize);
    } while (board[seed]!.terrain == Terrain.land);

    List<int> island = [seed];
    board[seed]!.terrain = Terrain.land;
    masterList.add(seed);

    int failsafe = 0;
    while (island.length < size && failsafe < 50) {
      if (!_expandLand(island, r, masterList: masterList)) {
        failsafe++;
      } else {
        failsafe = 0;
      }
    }
  }

  bool _expandLand(List<int> currentGroup, Random r, {List<int>? masterList}) {
    if (currentGroup.isEmpty) return false;
    int basePos = currentGroup[r.nextInt(currentGroup.length)];
    int row = basePos ~/ columns;
    int col = basePos % columns;

    List<int> neighbors = [];
    if (row > 0 && board[basePos - columns]!.terrain == Terrain.water) {
      neighbors.add(basePos - columns);
    }
    if (row < rows - 1 && board[basePos + columns]!.terrain == Terrain.water) {
      neighbors.add(basePos + columns);
    }
    if (col > 0 && board[basePos - 1]!.terrain == Terrain.water) {
      neighbors.add(basePos - 1);
    }
    if (col < columns - 1 && board[basePos + 1]!.terrain == Terrain.water) {
      neighbors.add(basePos + 1);
    }

    if (neighbors.isEmpty) return false;

    int nextPos = neighbors[r.nextInt(neighbors.length)];
    board[nextPos]!.terrain = Terrain.land;
    currentGroup.add(nextPos);
    masterList?.add(nextPos);
    return true;
  }

  void confirmPlacement() {
    if (isBoardValid) {
      HapticFeedback.heavyImpact();
      Get.find<GameController>()
          .startGame(columns, rows, board, myShips, enemyCount, playerName);
      Get.offAllNamed('/game');
    }
  }
}
