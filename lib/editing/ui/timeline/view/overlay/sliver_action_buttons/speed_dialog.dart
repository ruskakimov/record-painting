import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mooltik/common/data/project/fps_config.dart';
import 'package:mooltik/drawing/ui/layers/animated_layer_preview.dart';
import 'package:mooltik/common/ui/app_slider.dart';
import 'package:mooltik/common/ui/dialog_done_button.dart';
import 'package:mooltik/drawing/data/frame/frame.dart';

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
              Stack(
                children: [
                  _buildPreview(),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: _LabelBox('${animateOn}s'),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: _LabelBox(
                      '${(fps / animateOn).toStringAsFixed(2)} FPS',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildSlider(),
            ],
          ),
        ),
      ),
    );
  }

  ClipRRect _buildPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AnimatedLayerPreview(
        frames: widget.frames,
        frameDuration: singleFrameDuration * animateOn,
      ),
    );
  }

  Row _buildSlider() {
    return Row(
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
    );
  }
}

class _LabelBox extends StatelessWidget {
  const _LabelBox(
    this.text, {
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
