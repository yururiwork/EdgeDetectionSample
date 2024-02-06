import 'dart:ui';

import 'package:flutter/material.dart';

class EdgePainter extends CustomPainter {
  EdgePainter({
    required this.points,
    required this.color,
  });

  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
    ;

    const margin = 8.0;
    var path = Path()
      ..moveTo(points[0].dx - margin, points[0].dy - margin)
      ..lineTo(points[1].dx + margin, points[1].dy - margin)
      ..lineTo(points[2].dx + margin, points[2].dy + margin)
      ..lineTo(points[3].dx - margin, points[3].dy + margin)
    ;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}