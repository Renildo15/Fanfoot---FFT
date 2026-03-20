import 'package:fanfoot/core/enums/kit.dart';
import 'package:flutter/material.dart';

class KitPreview extends StatelessWidget {
  final String primaryColor;
  final String secondaryColor;
  final KitPattern pattern;
  final int? playerNumber;
  final double width;
  final double height;
  final bool isBack;

  const KitPreview({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    this.pattern = KitPattern.solid,
    this.playerNumber,
    this.width = 80,
    this.height = 100,
    this.isBack = false,
  });

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final primary = _hexToColor(primaryColor);
    final secondary = _hexToColor(secondaryColor);
    final textColor = primary.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            _buildShirtBody(primary, secondary, textColor),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: height * 0.15,
                decoration: BoxDecoration(
                  color: secondary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
            Positioned(
              top: height * 0.05,
              left: width * 0.05,
              right: width * 0.05,
              child: Container(
                height: height * 0.08,
                decoration: BoxDecoration(
                  color: secondary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            if (playerNumber != null && playerNumber! > 0)
              Center(
                child: Text(
                  playerNumber.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: height * 0.3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShirtBody(Color primary, Color secondary, Color textColor) {
    Widget shirt;

    switch (pattern) {
      case KitPattern.solid:
        shirt = Container(color: primary);
        break;
      case KitPattern.verticalStripes:
        shirt = Row(
          children: List.generate(6, (i) {
            return Expanded(
              child: Container(color: i % 2 == 0 ? primary : secondary),
            );
          }),
        );
        break;
      case KitPattern.horizontalStripes:
        shirt = Column(
          children: List.generate(5, (i) {
            return Expanded(
              child: Container(color: i % 2 == 0 ? primary : secondary),
            );
          }),
        );
        break;
      case KitPattern.diagonalStripes:
        shirt = Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primary, secondary, primary, secondary, primary],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
          ),
        );
        break;
      case KitPattern.quartered:
        shirt = Row(
          children: [
            Column(
              children: [
                Expanded(child: Container(color: primary)),
                Expanded(child: Container(color: secondary)),
              ],
            ),
            Column(
              children: [
                Expanded(child: Container(color: secondary)),
                Expanded(child: Container(color: primary)),
              ],
            ),
          ],
        );
        break;
      case KitPattern.halves:
        shirt = Row(
          children: [
            Expanded(child: Container(color: primary)),
            Expanded(child: Container(color: secondary)),
          ],
        );
        break;
      case KitPattern.gradient:
        shirt = Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primary, secondary],
            ),
          ),
        );
        break;
    }

    return shirt;
  }
}

class KitPreviewWithLabel extends StatelessWidget {
  final String primaryColor;
  final String secondaryColor;
  final KitPattern pattern;
  final int? playerNumber;
  final double width;
  final double height;
  final String label;

  const KitPreviewWithLabel({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    this.pattern = KitPattern.solid,
    this.playerNumber,
    this.width = 100,
    this.height = 130,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        KitPreview(
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          pattern: pattern,
          playerNumber: playerNumber,
          width: width,
          height: height,
        ),
      ],
    );
  }
}
