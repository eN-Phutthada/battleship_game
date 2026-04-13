import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/game_models.dart';
import '../state/placement_controller.dart';
import '../utils/constants.dart';
import '../widgets/shared_widgets.dart';

class PlacementScreen extends StatefulWidget {
  const PlacementScreen({super.key});

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
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
                      _buildSidebarContainer(
                        width: 80,
                        child: _buildLeftSidebar(ctrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _buildStatusHeader(ctrl),
                            Expanded(child: _buildAnimatedPaperGrid(ctrl)),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: ctrl.currentTool == PlacementTool.ship
                                  ? _buildShipOptionsBar(ctrl)
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildSidebarContainer(
                        width: 120,
                        child: _buildRightSidebar(ctrl),
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

  Widget _buildSidebarContainer(
      {required double width, required Widget child}) {
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

  Widget _buildLeftSidebar(PlacementController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Column(
        children: [
          Text(
            'tools'.tr,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Divider(color: AppColors.ink, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildToolButton(
                    ctrl: ctrl,
                    icon: Icons.landscape,
                    label: "${'land'.tr}\n${ctrl.placedLand}/${ctrl.maxLand}",
                    tool: PlacementTool.land,
                  ),
                  const SizedBox(height: 12),
                  _buildToolButton(
                    ctrl: ctrl,
                    icon: Icons.fort,
                    label:
                        "${'turret'.tr}\n${ctrl.placedTurrets}/${ctrl.maxTurrets}",
                    tool: PlacementTool.turret,
                  ),
                  const SizedBox(height: 12),
                  _buildToolButton(
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

  Widget _buildToolButton({
    required PlacementController ctrl,
    required IconData icon,
    required String label,
    required PlacementTool tool,
  }) {
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

  Widget _buildStatusHeader(PlacementController ctrl) {
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

  Widget _buildShipOptionsBar(PlacementController ctrl) {
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
          Text(
            'size'.tr,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
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
                    child: const Icon(
                      Icons.rotate_90_degrees_cw_outlined,
                      color: AppColors.ink,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ctrl.isHorizontal ? 'horz'.tr : 'vert'.tr,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPaperGrid(PlacementController ctrl) {
    final int displayCols = ctrl.columns + 1;
    final int displayRows = ctrl.rows + 1;
    final int totalItems = displayCols * displayRows;

    return Center(
      child: AspectRatio(
        aspectRatio: displayCols / displayRows,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.ink.withOpacity(0.5),
              width: 2.5,
            ),
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

              return InkWell(
                onTap: () => ctrl.handleTap(boardIdx),
                splashColor: AppColors.ink.withOpacity(0.3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.ink.withOpacity(0.2),
                      width: 1.0,
                    ),
                    color: cell.terrain == Terrain.land
                        ? Colors.brown[300]!.withOpacity(0.6)
                        : Colors.transparent,
                  ),
                  child: Center(
                    child: _buildCellContent(cell, boardIdx, ctrl),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCellContent(Cell cell, int index, PlacementController ctrl) {
    if (cell.entity == Entity.turret) {
      return const AnimatedScale(
        scale: 1.0,
        duration: Duration(milliseconds: 200),
        curve: Curves.bounceOut,
        child: FractionallySizedBox(
          widthFactor: 0.75,
          heightFactor: 0.75,
          child: FittedBox(
            child: Icon(Icons.fort, color: AppColors.ink),
          ),
        ),
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

  Widget _buildRightSidebar(PlacementController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
      child: Column(
        children: [
          Text(
            'command'.tr,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Divider(color: AppColors.ink, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildCommandButton(
                    onPressed: ctrl.autoDeploy,
                    icon: Icons.casino,
                    label: 'auto'.tr,
                    color: AppColors.ink,
                  ),
                  const SizedBox(height: 12),
                  _buildCommandButton(
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
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
                disabledBackgroundColor: Colors.grey.withOpacity(0.3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rocket_launch, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    'engage'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: color, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
