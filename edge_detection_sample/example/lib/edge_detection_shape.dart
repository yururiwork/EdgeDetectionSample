import 'dart:math';

import 'package:edge_detection_sample/edge_detection_sample.dart';
import 'package:edge_detection_sample_example/edge_painter.dart';
import 'package:flutter/material.dart';

class EdgeDetectionShape extends StatefulWidget {
  const EdgeDetectionShape({
    super.key,
    required this.renderedImageSize,
    required this.originalImageSize,
    required this.edgeDetectionResult,
  });

  final Size renderedImageSize;
  final Size originalImageSize;
  final EdgeDetectionResult edgeDetectionResult;

  @override
  State<EdgeDetectionShape> createState() => _EdgeDetectionShapeState();
}

class _EdgeDetectionShapeState extends State<EdgeDetectionShape> {
  late EdgeDetectionResult _edgeDetectionResult;
  late List<Offset> _points;

  @override
  void initState() {
    super.initState();
    _edgeDetectionResult = widget.edgeDetectionResult;
    _calculateDimensionValues();
  }

  @override
  void didUpdateWidget(covariant EdgeDetectionShape oldWidget) {
    super.didUpdateWidget(oldWidget);
    _edgeDetectionResult = widget.edgeDetectionResult;
    _calculateDimensionValues();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: EdgePainter(
        points: _points,
        color: Colors.green.withOpacity(0.5),
      ),
    );
  }

  void _calculateDimensionValues() {
    var top = 0.0;
    var left = 0.0;

    double widthFactor =
        widget.renderedImageSize.width / widget.originalImageSize.width;
    double heightFactor =
        widget.renderedImageSize.height / widget.originalImageSize.height;
    double sizeFactor = min(widthFactor, heightFactor);

    var renderedImageHeight = widget.originalImageSize.height * sizeFactor;
    top = ((widget.renderedImageSize.height - renderedImageHeight) / 2);

    var renderedImageWidth = widget.originalImageSize.width * sizeFactor;
    left = ((widget.renderedImageSize.width - renderedImageWidth) / 2);

    _points = [
      Offset(
        left + _edgeDetectionResult.topLeft.dx * renderedImageWidth,
        top + _edgeDetectionResult.topLeft.dy * renderedImageHeight,
      ),
      Offset(
        left + _edgeDetectionResult.topRight.dx * renderedImageWidth,
        top + _edgeDetectionResult.topRight.dy * renderedImageHeight,
      ),
      Offset(
        left + _edgeDetectionResult.bottomRight.dx * renderedImageWidth,
        top + (_edgeDetectionResult.bottomRight.dy * renderedImageHeight),
      ),
      Offset(
        left + _edgeDetectionResult.bottomLeft.dx * renderedImageWidth,
        top + _edgeDetectionResult.bottomLeft.dy * renderedImageHeight,
      ),
      // Offset(
      //   left + _edgeDetectionResult.topLeft.dx * renderedImageWidth,
      //   top + _edgeDetectionResult.topLeft.dy * renderedImageHeight,
      // ),
    ];
  }
}
