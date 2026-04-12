import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../state/placement_controller.dart';
import '../models/game_models.dart';
import '../utils/constants.dart';
import '../widgets/shared_widgets.dart';

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
                      Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.ink, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
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

                      Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.ink, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
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

  Widget _buildLeftSidebar(PlacementController ctrl) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          const SizedBox(height: 4),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _verticalToolBtn(
                    ctrl,
                    Icons.landscape,
                    "${'land'.tr}\n${ctrl.placedLand}/12",
                    PlacementTool.land,
                  ),
                  const SizedBox(height: 8),
                  _verticalToolBtn(
                    ctrl,
                    Icons.fort,
                    "${'turret'.tr}\n${ctrl.placedTurrets}/3",
                    PlacementTool.turret,
                  ),
                  const SizedBox(height: 8),
                  _verticalToolBtn(
                    ctrl,
                    Icons.directions_boat,
                    "${'fleet'.tr}\n${ctrl.placedShipsCount}/5",
                    PlacementTool.ship,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalToolBtn(
    PlacementController ctrl,
    IconData icon,
    String label,
    PlacementTool tool,
  ) {
    bool isSelected = ctrl.currentTool == tool;
    return GestureDetector(
      onTap: () => ctrl.setTool(tool),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.ink.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.ink : AppColors.ink.withOpacity(0.2),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.ink
                  : AppColors.ink.withOpacity(0.6),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? AppColors.ink
                    : AppColors.ink.withOpacity(0.6),
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
              children: [4, 3, 2, 1].map((size) {
                int count = ctrl.unplacedShips.where((s) => s == size).length;
                bool isSelected = ctrl.selectedShipSize == size;
                return GestureDetector(
                  onTap: count > 0 ? () => ctrl.selectShip(size) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: count == 0
                          ? Colors.grey.withOpacity(0.2)
                          : (isSelected ? AppColors.ink : Colors.white),
                      border: Border.all(
                        color: count == 0 ? Colors.transparent : AppColors.ink,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "L$size (x$count)",
                      style: TextStyle(
                        color: count == 0
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
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 7,
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 9,
            ),
            itemCount: 63,
            itemBuilder: (ctx, index) {
              int r = index ~/ 9;
              int c = index % 9;
              if (r == 0 && c == 0) return const SizedBox();
              if (r == 0) return GridHeaderCell('$c');
              if (c == 0) return GridHeaderCell(String.fromCharCode(64 + r));

              int boardIdx = (r - 1) * 8 + (c - 1);
              Cell cell = ctrl.board[boardIdx]!;

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
                  child: Center(child: _buildCellContent(cell, boardIdx, ctrl)),
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
      return AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.bounceOut,
        child: const Icon(Icons.fort, color: AppColors.ink, size: 24),
      );
    } else if (cell.entity == Entity.ship) {
      return AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 300),
        child: ConnectedShipPiece(
          index: index,
          shipId: cell.shipId!,
          board: ctrl.board,
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildRightSidebar(PlacementController ctrl) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          const SizedBox(height: 2),
          Text(
            'command'.tr,
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Divider(color: AppColors.ink, thickness: 1),
          const SizedBox(height: 8),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  OutlinedButton(
                    onPressed: ctrl.autoDeploy,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.ink, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.casino,
                          color: AppColors.ink,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'auto'.tr,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: ctrl.clearAll,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.redPen, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.delete_forever,
                          color: AppColors.redPen,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'clear'.tr,
                          style: const TextStyle(
                            color: AppColors.redPen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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
}
