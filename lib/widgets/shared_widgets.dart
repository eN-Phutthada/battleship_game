import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';

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

    return Container(
      margin: EdgeInsets.only(
        top: hasTop ? 0 : 4,
        bottom: hasBottom ? 0 : 4,
        left: hasLeft ? 0 : 4,
        right: hasRight ? 0 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.ink,
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
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(hasTop || hasLeft ? 0 : 4),
                topRight: Radius.circular(hasTop || hasRight ? 0 : 4),
                bottomLeft: Radius.circular(hasBottom || hasLeft ? 0 : 4),
                bottomRight: Radius.circular(hasBottom || hasRight ? 0 : 4),
              ),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
          ),
        ],
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
