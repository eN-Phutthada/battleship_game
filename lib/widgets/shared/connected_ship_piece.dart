import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/game_models.dart';
import '../../utils/constants.dart';
import '../../state/game_controller.dart';

class ConnectedShipPiece extends StatelessWidget {
  final int index;
  final String shipId;
  final Map<int, dynamic> board;
  final int columns;

  const ConnectedShipPiece({
    super.key,
    required this.index,
    required this.shipId,
    required this.board,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    bool hasTop = board[index - columns]?.shipId == shipId;
    bool hasBottom = board[index + columns]?.shipId == shipId;
    bool hasLeft = (index % columns != 0) && board[index - 1]?.shipId == shipId;
    bool hasRight =
        ((index + 1) % columns != 0) && board[index + 1]?.shipId == shipId;

    final theme = Get.isRegistered<GameController>()
        ? Get.find<GameController>().vehicleTheme
        : VehicleTheme.boat;

    Color baseColor;
    Color innerColor;
    Widget centerIcon;

    switch (theme) {
      case VehicleTheme.submarine:
        baseColor = const Color(0xFF006064);
        innerColor = Colors.white.withOpacity(0.2);
        centerIcon = const Icon(Icons.radar, size: 10, color: Colors.white);
        break;
      case VehicleTheme.space:
        baseColor = const Color(0xFF4A148C);
        innerColor = Colors.white.withOpacity(0.2);
        centerIcon = const Icon(Icons.bolt, size: 12, color: Colors.amber);
        break;
      case VehicleTheme.boat:
        baseColor = AppColors.ink;
        innerColor = Colors.white.withOpacity(0.25);
        centerIcon = Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.ink, width: 1.5),
          ),
        );
    }

    return Container(
      margin: EdgeInsets.only(
        top: hasTop ? 0 : 4,
        bottom: hasBottom ? 0 : 4,
        left: hasLeft ? 0 : 4,
        right: hasRight ? 0 : 4,
      ),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hasTop || hasLeft ? 0 : 8),
          topRight: Radius.circular(hasTop || hasRight ? 0 : 8),
          bottomLeft: Radius.circular(hasBottom || hasLeft ? 0 : 8),
          bottomRight: Radius.circular(hasBottom || hasRight ? 0 : 8),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: hasTop ? 0 : 4,
              bottom: hasBottom ? 0 : 4,
              left: hasLeft ? 0 : 4,
              right: hasRight ? 0 : 4,
            ),
            decoration: BoxDecoration(
              color: innerColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(hasTop || hasLeft ? 0 : 4),
                topRight: Radius.circular(hasTop || hasRight ? 0 : 4),
                bottomLeft: Radius.circular(hasBottom || hasLeft ? 0 : 4),
                bottomRight: Radius.circular(hasBottom || hasRight ? 0 : 4),
              ),
            ),
          ),
          centerIcon,
        ],
      ),
    );
  }
}

class TurretPiece extends StatelessWidget {
  const TurretPiece({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.isRegistered<GameController>()
        ? Get.find<GameController>().vehicleTheme
        : VehicleTheme.boat;

    IconData turretIcon;
    Color iconColor;
    Color baseColor;
    Color borderColor;

    switch (theme) {
      case VehicleTheme.submarine:
        turretIcon = Icons.cell_tower;
        iconColor = Colors.white;
        baseColor = Colors.teal[900]!;
        borderColor = Colors.tealAccent.withOpacity(0.6);
        break;
      case VehicleTheme.space:
        turretIcon = Icons.satellite_alt;
        iconColor = Colors.amberAccent;
        baseColor = Colors.black87;
        borderColor = Colors.deepPurpleAccent;
        break;
      case VehicleTheme.boat:
        turretIcon = Icons.fort;
        iconColor = AppColors.paper;
        baseColor = AppColors.ink;
        borderColor = AppColors.ink;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double size = (constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight) *
            0.75;

        return Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: baseColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black45, offset: Offset(2, 3), blurRadius: 3)
              ],
            ),
            child: Center(
              child: Icon(turretIcon, color: iconColor, size: size * 0.6),
            ),
          ),
        );
      },
    );
  }
}

class ThemedLandPiece extends StatelessWidget {
  final int index;
  final Map<int, dynamic> board;
  final int columns;

  const ThemedLandPiece({
    super.key,
    required this.index,
    required this.board,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    // 1. เช็คทิศทางตรง (เชื่อมต่อ 4 ทิศ)
    bool hasTop = board[index - columns]?.terrain == Terrain.land;
    bool hasBottom = board[index + columns]?.terrain == Terrain.land;
    bool hasLeft =
        (index % columns != 0) && board[index - 1]?.terrain == Terrain.land;
    bool hasRight = ((index + 1) % columns != 0) &&
        board[index + 1]?.terrain == Terrain.land;

    // 2. เช็คทิศทแยงมุม (เพื่อแก้บัค 270 องศา)
    bool hasTopLeft = (index % columns != 0) &&
        board[index - columns - 1]?.terrain == Terrain.land;
    bool hasTopRight = ((index + 1) % columns != 0) &&
        board[index - columns + 1]?.terrain == Terrain.land;
    bool hasBottomLeft = (index % columns != 0) &&
        board[index + columns - 1]?.terrain == Terrain.land;
    bool hasBottomRight = ((index + 1) % columns != 0) &&
        board[index + columns + 1]?.terrain == Terrain.land;

    final theme = Get.isRegistered<GameController>()
        ? Get.find<GameController>().vehicleTheme
        : VehicleTheme.boat;

    Color baseColor;
    Color borderColor;

    switch (theme) {
      case VehicleTheme.submarine:
        baseColor = Colors.teal[600]!;
        borderColor = Colors.teal[800]!;
        break;
      case VehicleTheme.space:
        baseColor = Colors.deepPurple[700]!;
        borderColor = Colors.deepPurple[900]!;
        break;
      case VehicleTheme.boat:
        baseColor = Colors.brown[300]!;
        borderColor = Colors.brown[500]!;
        break;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // เลเยอร์หลัก: พื้นแผ่นดินและการเชื่อมต่อ
        Container(
          margin: EdgeInsets.only(
            top: hasTop ? 0 : 2,
            bottom: hasBottom ? 0 : 2,
            left: hasLeft ? 0 : 2,
            right: hasRight ? 0 : 2,
          ),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(hasTop || hasLeft ? 0 : 6),
              topRight: Radius.circular(hasTop || hasRight ? 0 : 6),
              bottomLeft: Radius.circular(hasBottom || hasLeft ? 0 : 6),
              bottomRight: Radius.circular(hasBottom || hasRight ? 0 : 6),
            ),
            border: Border(
              top: hasTop
                  ? BorderSide.none
                  : BorderSide(color: borderColor, width: 2),
              bottom: hasBottom
                  ? BorderSide.none
                  : BorderSide(color: borderColor, width: 2),
              left: hasLeft
                  ? BorderSide.none
                  : BorderSide(color: borderColor, width: 2),
              right: hasRight
                  ? BorderSide.none
                  : BorderSide(color: borderColor, width: 2),
            ),
          ),
          child: _buildSubtleTexture(theme),
        ),

        // เลเยอร์เจาะช่อง: วาดขอบเข้ามุมในกรณี 270 องศา (รูปร่าง L-Shape)
        if (hasTop && hasLeft && !hasTopLeft)
          _buildInnerCorner(
            top: 0,
            left: 0,
            borderRight: true,
            borderBottom: true,
            radius: const BorderRadius.only(bottomRight: Radius.circular(4)),
            borderColor: borderColor,
          ),
        if (hasTop && hasRight && !hasTopRight)
          _buildInnerCorner(
            top: 0,
            right: 0,
            borderLeft: true,
            borderBottom: true,
            radius: const BorderRadius.only(bottomLeft: Radius.circular(4)),
            borderColor: borderColor,
          ),
        if (hasBottom && hasLeft && !hasBottomLeft)
          _buildInnerCorner(
            bottom: 0,
            left: 0,
            borderRight: true,
            borderTop: true,
            radius: const BorderRadius.only(topRight: Radius.circular(4)),
            borderColor: borderColor,
          ),
        if (hasBottom && hasRight && !hasBottomRight)
          _buildInnerCorner(
            bottom: 0,
            right: 0,
            borderLeft: true,
            borderTop: true,
            radius: const BorderRadius.only(topLeft: Radius.circular(4)),
            borderColor: borderColor,
          ),
      ],
    );
  }

  // วิดเจ็ตสำหรับแปะทับมุมใน 270 องศา เพื่อดัดขอบให้โค้งมนพอดี
  Widget _buildInnerCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    bool borderTop = false,
    bool borderBottom = false,
    bool borderLeft = false,
    bool borderRight = false,
    required BorderRadius radius,
    required Color borderColor,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 4, // ระยะ 4px คือผลรวมของ Margin(2) + Border(2) พอดีเป๊ะ
        height: 4,
        decoration: BoxDecoration(
          color:
              AppColors.paper, // ใช้สีพื้นกระดาษเหมือนเจาะทะลุไปหา Background
          borderRadius: radius,
          border: Border(
            top: borderTop
                ? BorderSide(color: borderColor, width: 2)
                : BorderSide.none,
            bottom: borderBottom
                ? BorderSide(color: borderColor, width: 2)
                : BorderSide.none,
            left: borderLeft
                ? BorderSide(color: borderColor, width: 2)
                : BorderSide.none,
            right: borderRight
                ? BorderSide(color: borderColor, width: 2)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSubtleTexture(VehicleTheme theme) {
    if (theme == VehicleTheme.space) {
      return Stack(
        children: [
          Positioned(top: 6, left: 6, child: _faintCrater()),
          Positioned(bottom: 8, right: 6, child: _faintCrater()),
        ],
      );
    } else if (theme == VehicleTheme.submarine) {
      return Stack(
        children: [
          Positioned(top: 8, right: 8, child: _faintBubble()),
          Positioned(bottom: 6, left: 10, child: _faintBubble()),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _faintCrater() => Container(
        width: 8,
        height: 8,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.black12),
      );

  Widget _faintBubble() => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1)),
      );
}
