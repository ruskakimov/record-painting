import 'package:flutter/material.dart';
import 'package:mooltik/common/data/project/fps_config.dart';
import 'package:mooltik/drawing/ui/layers/animated_layer_preview.dart';
import 'package:mooltik/common/ui/app_slider.dart';
import 'package:mooltik/common/ui/dialog_done_button.dart';
import 'package:mooltik/drawing/data/frame/frame.dart';
import 'package:mooltik/editing/data/timeline_view_model.dart';
import 'package:mooltik/editing/ui/timeline/view/overlay/sliver_action_buttons/sliver_action_button.dart';
import 'package:provider/provider.dart';

class SpeedButton extends StatelessWidget {
  const SpeedButton({
    Key? key,
    required this.rowIndex,
    required this.colIndex,
  }) : super(key: key);

  final int rowIndex;
  final int colIndex;

  @override
  Widget build(BuildContext context) {
    return SliverActionButton(
      iconData: Icons.speed,
      onPressed: () => _openSpeedDialog(context),
      rowIndex: rowIndex,
      colIndex: colIndex,
    );
  }

  void _openSpeedDialog(BuildContext context) {
    final timelineView = context.read<TimelineViewModel>();
    final layer = timelineView.sceneLayers[rowIndex];

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => SpeedDialog(
          frames: layer.frameSeq.iterable.toList(),
        ),
      ),
    );
  }
}

class SpeedDialog extends StatefulWidget {
  const SpeedDialog({
    Key? key,
    required this.frames,
  }) : super(key: key);

  final List<Frame> frames;

  @override
  _SpeedDialogState createState() => _SpeedDialogState();
}

class _SpeedDialogState extends State<SpeedDialog> {
  int animateOn = 5;

  void setAnimateOn(int value) {
    setState(() {
      animateOn = value.clamp(1, fps);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animation speed'),
        actions: [
          DialogDoneButton(onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AnimatedLayerPreview(
                  frames: widget.frames,
                  frameDuration: singleFrameDuration * animateOn,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () => setAnimateOn(animateOn + 1),
                  ),
                  Expanded(
                    child: AppSlider(
                      value: 1 - (animateOn - 1) / (fps - 1),
                      onChanged: (value) {
                        setAnimateOn(((1 - value) * (fps - 1) + 1).round());
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => setAnimateOn(animateOn - 1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
