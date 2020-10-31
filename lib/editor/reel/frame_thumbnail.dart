import 'package:flutter/material.dart';
import 'package:mooltik/editor/frame/frame_model.dart';
import 'package:mooltik/editor/frame/frame_painter.dart';

const double borderWidth = 4.0;

class FrameThumbnail extends StatelessWidget {
  const FrameThumbnail({
    Key key,
    @required this.frame,
    @required this.selected,
  }) : super(key: key);

  final FrameModel frame;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        color: selected ? Colors.amber : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    '${frame.duration}',
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.grey[850] : Colors.white,
                      fontWeight:
                          selected ? FontWeight.w900 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            Stack(
              children: [
                CustomPaint(
                  size: Size(
                    constraints.maxWidth - 24 - borderWidth,
                    constraints.maxHeight,
                  ),
                  painter: FramePainter(frame: frame),
                ),
                if (selected)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          vertical: BorderSide(
                            width: borderWidth,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: borderWidth),
          ],
        ),
      );
    });
  }
}
