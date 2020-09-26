import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mooltik/editor/drawer/pallete_tab/color_picker.dart';
import 'package:mooltik/editor/easel/easel_model.dart';
import 'package:mooltik/editor/toolbox/toolbox_model.dart';
import 'package:provider/provider.dart';

import 'package:mooltik/editor/gif.dart';
import 'package:mooltik/editor/drawer/drawer_icon_button.dart';
import 'package:mooltik/editor/drawer/pallete_tab/toolbar.dart';
import 'package:mooltik/editor/timeline/timeline_model.dart';

class PalleteTab extends StatefulWidget {
  const PalleteTab({Key key}) : super(key: key);

  @override
  _PalleteTabState createState() => _PalleteTabState();
}

class _PalleteTabState extends State<PalleteTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ToolBar(),
            Spacer(),
            SizedBox(width: 8),
            _buildDownloadButton(),
          ],
        ),
        _buildWidthSelector(),
        _buildColorSelector(),
      ],
    );
  }

  Widget _buildDownloadButton() {
    final timeline = context.watch<TimelineModel>();
    return DrawerIconButton(
      icon: FontAwesomeIcons.fileDownload,
      onTap: () async {
        final bytes =
            await makeGif(timeline.keyframes, timeline.animationDuration);
        await Share.file('Share GIF', 'image.gif', bytes, 'image/gif');
      },
    );
  }

  Widget _buildWidthSelector() {
    final toolbox = context.watch<ToolboxModel>();
    final width = toolbox.selectedTool.paint.strokeWidth;
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            '${width.toStringAsFixed(0)}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Expanded(
          child: Slider(
            value: width,
            min: 1.0,
            max: 100.0,
            onChanged: (value) {
              toolbox.changeStrokeWidth(value.round());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    final toolbox = context.watch<ToolboxModel>();
    final color = toolbox.selectedTool.paint.color;
    return Row(
      children: [
        ColorPicker(color: color),
        Expanded(
          child: Slider(
            value: color.opacity,
            onChanged: toolbox.changeOpacity,
          ),
        ),
      ],
    );
  }
}
