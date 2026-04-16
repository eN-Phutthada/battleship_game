import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/game_models.dart';
import '../state/placement_controller.dart';
import '../widgets/dialogs/abort_dialog.dart';
import '../widgets/shared/connected_ship_piece.dart'; // ให้แน่ใจว่ามี ThemedLandPiece และ TurretPiece อยู่ในนี้หรือ import มาครบนะครับ
import '../widgets/shared/animated_paper_bg.dart';
import '../utils/constants.dart';

class PlacementScreen extends StatelessWidget {
  const PlacementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (await showAbortDialog()) Get.offAllNamed('/');
      },
      child: Scaffold(
        backgroundColor: AppColors.paper,
        body: AnimatedPaperBackground(
          child: SafeArea(
            child: GetBuilder<PlacementController>(
              init: PlacementController(),
              builder: (ctrl) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SidebarContainer(
                        width: 80,
                        child: _LeftSidebar(ctrl: ctrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _StatusHeader(ctrl: ctrl),
                            Expanded(child: _AnimatedPaperGrid(ctrl: ctrl)),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: ctrl.currentTool == PlacementTool.ship
                                  ? _ShipOptionsBar(ctrl: ctrl)
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SidebarContainer(
                        width: 120,
                        child: _RightSidebar(ctrl: ctrl),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// EXTRACTED WIDGETS
// ==========================================

class SidebarContainer extends StatelessWidget {
  final double width;
  final Widget child;

  const SidebarContainer({super.key, required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class _LeftSidebar extends StatelessWidget {
  final PlacementController ctrl;
  const _LeftSidebar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Column(
        children: [
          Text('tools'.tr,
              style: const TextStyle(
                  color: AppColors.ink, fontWeight: FontWeight.w900)),
          const Divider(color: AppColors.ink, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _ToolButton(
                    ctrl: ctrl,
                    icon: Icons.landscape,
                    label: "${'land'.tr}\n${ctrl.placedLand}/${ctrl.maxLand}",
                    tool: PlacementTool.land,
                  ),
                  const SizedBox(height: 12),
                  _ToolButton(
                    ctrl: ctrl,
                    icon: Icons.fort,
                    label:
                        "${'turret'.tr}\n${ctrl.placedTurrets}/${ctrl.maxTurrets}",
                    tool: PlacementTool.turret,
                  ),
                  const SizedBox(height: 12),
                  _ToolButton(
                    ctrl: ctrl,
                    icon: Icons.directions_boat,
                    label:
                        "${'fleet'.tr}\n${ctrl.placedShipsCount}/${ctrl.fleetDefinition.length}",
                    tool: PlacementTool.ship,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RightSidebar extends StatelessWidget {
  final PlacementController ctrl;
  const _RightSidebar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
      child: Column(
        children: [
          Text('command'.tr,
              style: const TextStyle(
                  color: AppColors.ink, fontWeight: FontWeight.w900)),
          const Divider(color: AppColors.ink, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _CommandButton(
                    onPressed: ctrl.autoDeploy,
                    icon: Icons.casino,
                    label: 'auto'.tr,
                    color: AppColors.ink,
                  ),
                  const SizedBox(height: 12),
                  _CommandButton(
                    onPressed: ctrl.clearAll,
                    icon: Icons.delete_forever,
                    label: 'clear'.tr,
                    color: AppColors.redPen,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 70,
            child: ElevatedButton(
              onPressed: ctrl.isBoardValid ? ctrl.confirmPlacement : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ctrl.isBoardValid
                    ? Colors.green[700]
                    : Colors.grey.withOpacity(0.3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
                disabledBackgroundColor: Colors.grey.withOpacity(0.3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rocket_launch, size: 24),
                  const SizedBox(height: 4),
                  Text('engage'.tr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final PlacementController ctrl;
  const _StatusHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(ctrl.validationMessage),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.ink, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            ctrl.validationMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ctrl.isBoardValid ? Colors.green[800] : AppColors.redPen,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShipOptionsBar extends StatelessWidget {
  final PlacementController ctrl;
  const _ShipOptionsBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.ink, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('size'.tr,
              style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: ctrl.fleetDefinition.toSet().map((size) {
                final int count =
                    ctrl.unplacedShips.where((s) => s == size).length;
                final bool isSelected = ctrl.selectedShipSize == size;
                final bool isAvailable = count > 0;

                return GestureDetector(
                  onTap: isAvailable ? () => ctrl.selectShip(size) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: !isAvailable
                          ? Colors.grey.withOpacity(0.2)
                          : (isSelected ? AppColors.ink : Colors.white),
                      border: Border.all(
                        color:
                            !isAvailable ? Colors.transparent : AppColors.ink,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "L$size (x$count)",
                      style: TextStyle(
                        color: !isAvailable
                            ? Colors.grey
                            : (isSelected ? Colors.white : AppColors.ink),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          InkWell(
            onTap: ctrl.toggleOrientation,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.ink, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedRotation(
                    turns: ctrl.isHorizontal ? 0 : 0.25,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.rotate_90_degrees_cw_outlined,
                        color: AppColors.ink, size: 16),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ctrl.isHorizontal ? 'horz'.tr : 'vert'.tr,
                    style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedPaperGrid extends StatelessWidget {
  final PlacementController ctrl;
  const _AnimatedPaperGrid({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final int displayCols = ctrl.columns + 1;
    final int displayRows = ctrl.rows + 1;
    final int totalItems = displayCols * displayRows;

    return Center(
      child: AspectRatio(
        aspectRatio: displayCols / displayRows,
        child: Container(
          decoration: BoxDecoration(
            border:
                Border.all(color: AppColors.ink.withOpacity(0.5), width: 2.5),
            color: AppColors.paper.withOpacity(0.85),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: displayCols,
            ),
            itemCount: totalItems,
            itemBuilder: (ctx, index) {
              final int r = index ~/ displayCols;
              final int c = index % displayCols;

              if (r == 0 && c == 0) return const SizedBox.shrink();
              if (r == 0) return GridHeaderCell('$c');
              if (c == 0) return GridHeaderCell(String.fromCharCode(64 + r));

              final int boardIdx = (r - 1) * ctrl.columns + (c - 1);
              final Cell? cell = ctrl.board[boardIdx];
              if (cell == null) return const SizedBox.shrink();

              // ภายในคลาส _AnimatedPaperGrid
              return InkWell(
                onTap: () => ctrl.handleTap(boardIdx),
                splashColor: AppColors.ink.withOpacity(0.3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Layer แผ่นดิน (Land) - แสดงผลตามธีม
                      if (cell.terrain == Terrain.land)
                        ThemedLandPiece(
                          index: boardIdx,
                          board: ctrl.board,
                          columns: ctrl.columns,
                        ),

                      // 2. ✨ Layer เส้นตาราง (Faint Grid Lines) บนแผ่นดิน ✨
                      // เราใช้ Opacity ต่ำๆ เพื่อให้เห็นเส้นจางๆ
                      if (cell.terrain == Terrain.land)
                        Opacity(
                          opacity:
                              0.1, // ปรับความจางของเส้นตารางบนแผ่นดินที่นี่ (0.0 - 1.0)
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.ink,
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),

                      // 3. Layer เส้นตารางหลัก (Main Grid Lines) - สำหรับพื้นที่ที่ไม่ใช่ Land
                      if (cell.terrain != Terrain.land)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.ink.withOpacity(
                                  0.2), // ความชัดเจนของเส้นตารางปกติ
                              width: 0.5,
                            ),
                          ),
                        ),

                      // 4. Layer เนื้อหา (Ships/Turrets) วางทับด้านบนสุด
                      Center(
                        child: _CellContent(
                            cell: cell, index: boardIdx, ctrl: ctrl),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class GridHeaderCell extends StatelessWidget {
  final String text;
  const GridHeaderCell(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    // ปรับให้ GridHeader มีความหนาของเส้นตารางเข้ากันได้พอดี
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ink.withOpacity(0.05),
        border: Border.all(
          color: AppColors.ink.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _CellContent extends StatelessWidget {
  final Cell cell;
  final int index;
  final PlacementController ctrl;

  const _CellContent({
    required this.cell,
    required this.index,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    if (cell.entity == Entity.turret) {
      return const AnimatedScale(
        scale: 1.0,
        duration: Duration(milliseconds: 200),
        curve: Curves.bounceOut,
        child: TurretPiece(), // ตัวมันเองจัดการขนาดให้พอดีแล้ว
      );
    } else if (cell.entity == Entity.ship) {
      return AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 300),
        child: Transform.scale(
          scale: 1.1,
          child: ConnectedShipPiece(
            index: index,
            shipId: cell.shipId!,
            board: ctrl.board,
            columns: ctrl.columns,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _ToolButton extends StatelessWidget {
  final PlacementController ctrl;
  final IconData icon;
  final String label;
  final PlacementTool tool;

  const _ToolButton({
    required this.ctrl,
    required this.icon,
    required this.label,
    required this.tool,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = ctrl.currentTool == tool;
    final Color contentColor =
        isSelected ? AppColors.ink : AppColors.ink.withOpacity(0.6);

    return GestureDetector(
      onTap: () => ctrl.setTool(tool),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.ink.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.ink : AppColors.ink.withOpacity(0.2),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: contentColor, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: contentColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _CommandButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: color, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(double.infinity, 0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
