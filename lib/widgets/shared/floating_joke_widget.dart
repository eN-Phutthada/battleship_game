import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class FloatingJokeWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Offset startPosition;
  final VoidCallback onComplete;

  const FloatingJokeWidget({
    super.key,
    required this.message,
    required this.icon,
    required this.startPosition,
    required this.onComplete,
  });

  @override
  State<FloatingJokeWidget> createState() => _FloatingJokeWidgetState();
}

class _FloatingJokeWidgetState extends State<FloatingJokeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _opacityAnim;
  late Animation<double> _translateAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));

    _opacityAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_animController);

    _translateAnim = Tween(begin: 0.0, end: -20.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));

    _animController.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // คำนวณเปอร์เซ็นต์แกน X (-1.0 ซ้ายสุด, 0.0 ตรงกลาง, 1.0 ขวาสุด)
    // เว้นระยะขอบ 10px ให้ไม่ล้นจอ
    double alignX =
        ((widget.startPosition.dx - 10) / (screenWidth - 20)) * 2 - 1;
    alignX = alignX.clamp(-1.0, 1.0);

    return Positioned(
      left: 20,
      right: 20,
      top: widget.startPosition.dy,
      child: FractionalTranslation(
        translation: const Offset(0.0, -1.0),
        child: Align(
          alignment: Alignment(alignX, 1.0),
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _translateAnim.value),
                child: Opacity(
                  opacity: _opacityAnim.value,
                  child: child,
                ),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: Transform.rotate(
                angle: -0.05,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.ink, width: 2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: AppColors.ink, offset: Offset(4, 4))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, color: AppColors.ink, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
