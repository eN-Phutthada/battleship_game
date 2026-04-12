import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../models/game_models.dart';

class AnimatedPaperBackground extends StatefulWidget {
  final Widget child;
  const AnimatedPaperBackground({super.key, required this.child});
  @override
  State<AnimatedPaperBackground> createState() =>
      _AnimatedPaperBackgroundState();
}

class _AnimatedPaperBackgroundState extends State<AnimatedPaperBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) => CustomPaint(
        painter: PaperGridPainter(
          AppColors.ink.withOpacity(0.1),
          _bgController.value,
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class PaperGridPainter extends CustomPainter {
  final Color lineColor;
  final double animationProgress;
  PaperGridPainter(this.lineColor, this.animationProgress);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;
    const double gridSize = 30.0;
    final double offset = animationProgress * gridSize;
    for (double i = -gridSize + offset; i <= size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = -gridSize + offset; i <= size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant PaperGridPainter oldDelegate) =>
      oldDelegate.animationProgress != animationProgress;
}

Future<bool> showAbortDialog() async {
  return await Get.dialog<bool>(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.paper,
              border: Border.all(color: AppColors.redPen, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black26, offset: Offset(6, 6)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.redPen,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'abort_title'.tr,
                      style: const TextStyle(
                        color: AppColors.redPen,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.blueGrey, height: 20),
                Text(
                  'abort_desc'.tr,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        'stay'.tr,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redPen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () => Get.back(result: true),
                      child: Text(
                        'retreat'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ) ??
      false;
}

class ConnectedShipPiece extends StatelessWidget {
  final int index;
  final String shipId;
  final Map<int, Cell> board;
  const ConnectedShipPiece({
    super.key,
    required this.index,
    required this.shipId,
    required this.board,
  });
  @override
  Widget build(BuildContext context) {
    int cols = 8;
    bool hasLeft = (index % cols != 0) && board[index - 1]?.shipId == shipId;
    bool hasRight =
        (index % cols != cols - 1) && board[index + 1]?.shipId == shipId;
    bool hasTop = (index >= cols) && board[index - cols]?.shipId == shipId;
    bool hasBottom =
        (index < 48 - cols) && board[index + cols]?.shipId == shipId;
    return Container(
      margin: EdgeInsets.only(
        left: hasLeft ? 0 : 3,
        right: hasRight ? 0 : 3,
        top: hasTop ? 0 : 3,
        bottom: hasBottom ? 0 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.ink.withOpacity(0.15),
        border: Border(
          left: hasLeft
              ? BorderSide.none
              : const BorderSide(color: AppColors.ink, width: 2.5),
          right: hasRight
              ? BorderSide.none
              : const BorderSide(color: AppColors.ink, width: 2.5),
          top: hasTop
              ? BorderSide.none
              : const BorderSide(color: AppColors.ink, width: 2.5),
          bottom: hasBottom
              ? BorderSide.none
              : const BorderSide(color: AppColors.ink, width: 2.5),
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(hasLeft || hasTop ? 0 : 4),
          topRight: Radius.circular(hasRight || hasTop ? 0 : 4),
          bottomLeft: Radius.circular(hasLeft || hasBottom ? 0 : 4),
          bottomRight: Radius.circular(hasRight || hasBottom ? 0 : 4),
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
    return Container(
      color: AppColors.ink.withOpacity(0.05),
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
