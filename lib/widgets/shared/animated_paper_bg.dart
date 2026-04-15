import 'package:flutter/material.dart';
import '../../utils/constants.dart';

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
