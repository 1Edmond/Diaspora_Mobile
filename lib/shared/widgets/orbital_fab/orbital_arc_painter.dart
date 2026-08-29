import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'orbital_data.dart';

class OrbitalArcPainter extends CustomPainter {
  final List<OrbitalItem> items;
  final int selectedIndex;
  final double centerX;
  final double centerY;
  final double radius;
  final double animation;

  OrbitalArcPainter({
    required this.items,
    required this.selectedIndex,
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (items.length < 2) return;

    const topMargin = 50.0;
    const bottomMargin = 50.0;
    final usableHeight = size.height - topMargin - bottomMargin;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final itemPositions = <Offset>[];

    for (int i = 0; i < items.length; i++) {
      final t = items.length <= 1 ? 0.5 : i / (items.length - 1);
      final y = topMargin + usableHeight * t;
      final arcOffset = math.sin(t * math.pi) * radius * 0.3;
      final x = centerX + arcOffset;
      itemPositions.add(Offset(x, y));
    }

    for (int i = 0; i < itemPositions.length - 1; i++) {
      final p1 = itemPositions[i];
      final p2 = itemPositions[i + 1];

      final isHighlighted = i == selectedIndex || i + 1 == selectedIndex;

      paint
        ..color = isHighlighted
            ? items[i].color.withValues(alpha: 0.3 * animation)
            : Colors.grey.withValues(alpha: 0.15 * animation)
        ..strokeWidth = isHighlighted ? 2.0 : 1.2;

      final controlPoint1 = Offset(
        centerX + radius * 0.1,
        (p1.dy + p2.dy) / 2 - 10,
      );
      final controlPoint2 = Offset(
        centerX + radius * 0.1,
        (p1.dy + p2.dy) / 2 + 10,
      );

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p2.dx,
          p2.dy,
        );

      canvas.drawPath(path, paint);
    }

    for (int i = 0; i < itemPositions.length; i++) {
      final p = itemPositions[i];
      final paintDot = Paint()
        ..color = items[i].color.withValues(alpha: 0.4 * animation)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(p, 3, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant OrbitalArcPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.animation != animation;
  }
}

/// Draws the connecting arc for the scrollable orbital layout, where each
/// item occupies a fixed vertical block instead of being distributed across
/// the viewport height. This keeps the arc aligned with items even when the
/// list scrolls (the painter is sized to the full content height).
class ScrollableArcPainter extends CustomPainter {
  final int itemCount;
  final int selectedIndex;
  final double centerX;
  final double itemBlockHeight;
  final double horizontalRadius;
  final double animation;

  ScrollableArcPainter({
    required this.itemCount,
    required this.selectedIndex,
    required this.centerX,
    required this.itemBlockHeight,
    required this.horizontalRadius,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount < 2) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Center of each item's icon (dots land on the icon centers).
    final itemPositions = <Offset>[];
    for (int i = 0; i < itemCount; i++) {
      final centerY = itemBlockHeight * i + itemBlockHeight / 2;
      final t = itemCount <= 1 ? 0.5 : i / (itemCount - 1);
      final arcOffset = math.sin(t * math.pi) * horizontalRadius;
      itemPositions.add(Offset(centerX + arcOffset, centerY));
    }

    // Connecting segments: smooth S-curves with horizontal mid-tangents so
    // the overall shape reads as a gentle arc (not a straight line).
    for (int i = 0; i < itemPositions.length - 1; i++) {
      final p1 = itemPositions[i];
      final p2 = itemPositions[i + 1];

      final isHighlighted = i == selectedIndex || i + 1 == selectedIndex;
      paint
        ..color = isHighlighted
            ? const Color(0xFF0033A0).withValues(alpha: 0.3 * animation)
            : Colors.grey.withValues(alpha: 0.15 * animation)
        ..strokeWidth = isHighlighted ? 2.0 : 1.2;

      final midY = (p1.dy + p2.dy) / 2;

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..cubicTo(
          p1.dx,
          midY,
          p2.dx,
          midY,
          p2.dx,
          p2.dy,
        );

      canvas.drawPath(path, paint);
    }

    for (int i = 0; i < itemPositions.length; i++) {
      final p = itemPositions[i];
      final paintDot = Paint()
        ..color = Colors.grey.withValues(alpha: 0.4 * animation)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p, 3, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant ScrollableArcPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.animation != animation;
  }
}
