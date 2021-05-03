import 'package:flutter/material.dart';
import 'package:mooltik/common/data/project/composite_image.dart';
import 'package:mooltik/common/ui/composite_image_painter.dart';
import 'package:mooltik/drawing/drawing_page.dart';
import 'package:mooltik/editing/data/timeline_model.dart';
import 'package:mooltik/common/data/project/project.dart';
import 'package:provider/provider.dart';

class Preview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        final project = context.read<Project>();
        final timeline = context.read<TimelineModel>();

        if (timeline.isPlaying) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: project),
                ChangeNotifierProvider.value(value: timeline),
              ],
              child: DrawingPage(),
            ),
          ),
        );
      },
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: CustomPaint(
          painter: CompositeImagePainter(
            context.select<TimelineModel, CompositeImage>(
              (timeline) => timeline.currentFrame,
            ),
          ),
        ),
      ),
    );
  }
}
