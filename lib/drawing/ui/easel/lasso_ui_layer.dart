import 'package:flutter/material.dart';
import 'package:mooltik/drawing/data/frame/stroke.dart';
import 'package:mooltik/drawing/data/toolbox/tools/tools.dart';
import 'package:provider/provider.dart';
import 'package:mooltik/drawing/data/easel_model.dart';

class LassoUiLayer extends StatelessWidget {
  const LassoUiLayer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final easel = context.watch<EaselModel>();
    final lasso = context.watch<Lasso>();

    return Transform.translate(
      offset: Offset.zero,
      child: lasso.selectionStroke != null
          ? CustomPaint(
              size: lasso.selectionStroke.boundingRect.size * easel.scale,
              painter: SelectionPainter(lasso.selectionStroke),
            )
          : null,
    );
  }
}

class SelectionPainter extends CustomPainter {
  SelectionPainter(this.selectionStroke);

  final Stroke selectionStroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / selectionStroke.boundingRect.width);

    selectionStroke.paintOn(canvas);
    print(size);
  }

  @override
  bool shouldRepaint(SelectionPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(SelectionPainter oldDelegate) => false;
}
