import 'package:flutter/material.dart';
import '../../utils/constants.dart';

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
