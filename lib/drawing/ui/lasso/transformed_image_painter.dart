import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Paints transformed image over the frame. Must be the size of the frame.
class TransformedImagePainter extends CustomPainter {
  TransformedImagePainter({
    @required this.transformedImage,
    @required this.transform,
  });

  final ui.Image transformedImage;
  final Matrix4 transform;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.transform(transform.storage);

    canvas.drawImage(
      transformedImage,
      Offset.zero,
      Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(TransformedImagePainter oldDelegate) =>
      oldDelegate.transformedImage != transformedImage ||
      oldDelegate.transform != transform;

  @override
  bool shouldRebuildSemantics(TransformedImagePainter oldDelegate) => false;
}
