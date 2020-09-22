import 'dart:math';

import 'package:flutter/material.dart';

class TimelinePainter extends CustomPainter {
  TimelinePainter({
    @required this.frameWidth,
    @required this.offset,
    @required this.emptyKeyframes,
    @required this.keyframes,
  });

  final double frameWidth;
  final double offset;
  final List<int> emptyKeyframes;
  final List<int> keyframes;

  final linePaint = Paint()
    ..color = Colors.grey[200]
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  final keyframePaint = Paint()
    ..color = Colors.grey[200]
    ..style = PaintingStyle.fill;

  double _frameX(int frameNumber, double midX) {
    return midX - offset + (frameNumber - 1) * frameWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = Colors.black.withOpacity(0.2);

    final midX = size.width / 2;
    final midY = size.height / 2;
    final firstFrameX = _frameX(1, midX);

    // Frame grid.
    final gridStart =
        firstFrameX < 0 ? -(firstFrameX.abs() % (frameWidth * 2)) : firstFrameX;
    for (var x = gridStart; x <= size.width; x += frameWidth * 2) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, frameWidth, size.height),
        gridPaint,
      );
    }

    // Draw timeline and empty keyframes on a new layer, so [BlendMode.clear] is applied.
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Timeline.
    canvas.drawLine(
      Offset(max(firstFrameX, 0), midY),
      Offset(size.width, midY),
      linePaint,
    );

    for (final keyframeNumber in emptyKeyframes) {
      _drawEmptyKeyframe(
        canvas,
        Offset(_frameX(keyframeNumber, midX), midY),
      );
    }

    // Merge and erase line inside empty keyframe.
    canvas.restore();

    for (final keyframeNumber in keyframes) {
      _drawKeyframe(
        canvas,
        Offset(_frameX(keyframeNumber, midX), midY),
      );
    }

    // Playhead.
    canvas.drawLine(
      Offset(midX, 0),
      Offset(midX, size.height),
      Paint()
        ..color = Colors.amber
        ..strokeWidth = 2,
    );
  }

  void _drawEmptyKeyframe(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 8, Paint()..blendMode = BlendMode.clear);
    canvas.drawCircle(center, 8, linePaint);
  }

  void _drawKeyframe(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 8, keyframePaint);
  }

  @override
  bool shouldRepaint(TimelinePainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(TimelinePainter oldDelegate) => false;
}
