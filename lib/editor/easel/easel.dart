import 'package:flutter/material.dart';
import 'package:mooltik/editor/easel/easel_model.dart';
import 'package:mooltik/editor/frame/frame_model.dart';
import 'package:mooltik/editor/timeline/timeline_model.dart';
import 'package:mooltik/home/project.dart';
import 'package:provider/provider.dart';
import 'package:mooltik/editor/toolbox/toolbox_model.dart';

import '../frame/frame_painter.dart';
import 'easel_gesture_detector.dart';

class Easel extends StatefulWidget {
  Easel({Key key}) : super(key: key);

  @override
  _EaselState createState() => _EaselState();
}

class _EaselState extends State<Easel> {
  @override
  Widget build(BuildContext context) {
    final project = context.watch<Project>();
    final timeline = context.watch<TimelineModel>();
    final toolbox = context.watch<ToolboxModel>();

    return ChangeNotifierProxyProvider2<TimelineModel, ToolboxModel,
        EaselModel>(
      create: (_) => EaselModel(
        frame: timeline.selectedFrame,
        frameSize: project.frameSize,
        selectedTool: toolbox.selectedTool,
        screenSize: MediaQuery.of(context).size,
      ),
      update: (_, reel, toolbox, easel) => easel
        ..updateFrame(reel.selectedFrame)
        ..updateSelectedTool(toolbox.selectedTool)
        ..updateSelectedColor(toolbox.selectedColor),
      builder: (context, child) {
        final easel = context.watch<EaselModel>();
        final frame = context.watch<FrameModel>();

        return EaselGestureDetector(
          onStrokeStart: easel.onStrokeStart,
          onStrokeUpdate: easel.onStrokeUpdate,
          onStrokeEnd: easel.onStrokeEnd,
          onStrokeCancel: easel.onStrokeCancel,
          onScaleStart: easel.onScaleStart,
          onScaleUpdate: easel.onScaleUpdate,
          onTwoFingerTap: frame.undo,
          onThreeFingerTap: frame.redo,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: Colors.transparent),
              Positioned(
                top: easel.canvasTopOffset,
                left: easel.canvasLeftOffset,
                width: easel.canvasWidth,
                height: easel.canvasHeight,
                child: Transform.rotate(
                  alignment: Alignment.topLeft,
                  angle: easel.canvasRotation,
                  child: RepaintBoundary(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          width: frame.width,
                          height: frame.height,
                          color: Colors.white,
                        ),
                        // if (reel.frameBefore != null)
                        //   Opacity(
                        //     opacity: 0.2,
                        //     child: CustomPaint(
                        //       size: Size(frame.width, frame.height),
                        //       foregroundPainter: FramePainter(
                        //         frame: reel.frameBefore,
                        //         background: Colors.transparent,
                        //         filter: ColorFilter.mode(
                        //           Colors.red,
                        //           BlendMode.srcATop,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // if (reel.frameAfter != null)
                        //   Opacity(
                        //     opacity: 0.2,
                        //     child: CustomPaint(
                        //       size: Size(frame.width, frame.height),
                        //       foregroundPainter: FramePainter(
                        //         frame: reel.frameAfter,
                        //         background: Colors.transparent,
                        //         filter: ColorFilter.mode(
                        //           Colors.green,
                        //           BlendMode.srcATop,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        CustomPaint(
                          size: Size(frame.width, frame.height),
                          foregroundPainter: FramePainter(
                            frame: frame,
                            strokes: [
                              if (easel.currentStroke != null)
                                easel.currentStroke,
                            ],
                            showCursor: true,
                            background: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
