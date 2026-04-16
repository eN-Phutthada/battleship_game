enum Terrain { water, land }

enum Entity { none, ship, turret }

enum VehicleTheme { boat, submarine, space }

class ShipData {
  final String id;
  final int size;
  final List<int> positions;
  bool isSunk;

  ShipData({
    required this.id,
    required this.size,
    required this.positions,
    this.isSunk = false,
  });
}

class Cell {
  Terrain terrain;
  Entity entity;
  bool isRevealed;
  String? shipId;

  Cell({
    this.terrain = Terrain.water,
    this.entity = Entity.none,
    this.isRevealed = false,
    this.shipId,
  });
}

class PlayerData {
  final int id;
  final String name;
  final bool isBot;
  Map<int, Cell> board = {};
  List<ShipData> ships = [];
  int bonusAmmo = 0;

  PlayerData({required this.id, required this.name, this.isBot = false});

  int get activeTurrets {
    return board.values
        .where((c) => c.entity == Entity.turret && !c.isRevealed)
        .length;
  }

  int get currentAmmo => 1 + activeTurrets + bonusAmmo;

  bool get isDefeated {
    return board.values
        .where(
          (c) =>
              (c.entity == Entity.ship || c.entity == Entity.turret) &&
              !c.isRevealed,
        )
        .isEmpty;
  }
}
