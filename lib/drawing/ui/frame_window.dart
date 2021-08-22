import 'package:flutter/material.dart';
import 'package:mooltik/drawing/data/frame/frame.dart';
import 'package:mooltik/drawing/ui/canvas_painter.dart';

const frostedGlassColor = Color(0x88A09F9F);

class FrameWindow extends StatelessWidget {
  const FrameWindow({
    Key? key,
    required this.frame,
  }) : super(key: key);

  final Frame frame;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: frostedGlassColor,
          child: CustomPaint(
            isComplex: true,
            foregroundPainter: CanvasPainter(image: frame.image.snapshot),
          ),
        ),
      ),
    );
  }
}
