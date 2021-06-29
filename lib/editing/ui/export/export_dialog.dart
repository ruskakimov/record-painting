import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mooltik/editing/data/exporter_model.dart';
import 'package:provider/provider.dart';
import 'package:mooltik/common/ui/editable_field.dart';

class ExportDialog extends StatefulWidget {
  const ExportDialog({
    Key? key,
  }) : super(key: key);

  @override
  _ExportDialogState createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  @override
  Widget build(BuildContext context) {
    final exporter = context.watch<ExporterModel>();

    return WillPopScope(
      onWillPop: () async => exporter.isInitial,
      child: SimpleDialog(
        contentPadding: const EdgeInsets.all(16),
        children: [
          ExporterForm(
            selectedOption: exporter.selectedOption,
            onValueChanged: exporter.onExportOptionChanged,
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    final exporter = context.watch<ExporterModel>();

    if (exporter.isInitial)
      return _buildExportButton();
    else if (exporter.isExporting)
      return _buildButtonsForProgress();
    else
      return _buildButtonsForDone();
  }

  Widget _buildExportButton() {
    return ElevatedButton(
      child: Text('Export'),
      onPressed: () {
        final exporter = context.read<ExporterModel>();
        exporter.start();
      },
    );
  }

  Widget _buildButtonsForProgress() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            child: Text('Cancel'),
            onPressed: () {},
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            child: Text('Share'),
            onPressed: null,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsForDone() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            child: Text('Done'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            child: Text('Share'),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

class ExporterForm extends StatelessWidget {
  const ExporterForm({
    Key? key,
    required this.selectedOption,
    required this.onValueChanged,
  }) : super(key: key);

  final ExportOption selectedOption;
  final ValueChanged<ExportOption?> onValueChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTitle(),
        SizedBox(height: 8),
        _buildOptionMenu(),
        _buildForm(),
      ],
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Export as',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOptionMenu() {
    return CupertinoSlidingSegmentedControl<ExportOption>(
      backgroundColor: Colors.black.withOpacity(0.25),
      groupValue: selectedOption,
      children: {
        ExportOption.video: Text('Video'),
        ExportOption.images: Text('Images'),
      },
      onValueChanged: onValueChanged,
    );
  }

  Widget _buildForm() {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 300),
      crossFadeState: selectedOption == ExportOption.video
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: EditableField(
        label: 'File name',
        text: '123123.mp4',
        onTap: () {},
      ),
      secondChild: EditableField(
        label: 'Selected frames',
        text: '148',
        onTap: () {},
      ),
    );
  }
}

// class ExportDialog extends StatelessWidget {
//   const ExportDialog({
//     Key? key,
//     this.sideWidth = 280,
//     this.loadingStrokeWidth = 20,
//   })  : assert(
//           sideWidth >= 280,
//           'Minimum flutter dialog width is 280px.',
//         ),
//         assert(loadingStrokeWidth < sideWidth / 2),
//         super(key: key);

//   final double sideWidth;
//   final double loadingStrokeWidth;

//   @override
//   Widget build(BuildContext context) {
//     final exporter = context.watch<ExporterModel>();

//     return PortalEntry(
//       visible: exporter.isExporting,
//       portal: AbsorbPointer(),
//       child: Dialog(
//         shape: CircleBorder(),
//         child: SizedBox(
//           width: sideWidth,
//           height: sideWidth,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Positioned.fill(
//                 child: _LoadingIndicator(
//                   value: exporter.progress,
//                   strokeWidth: loadingStrokeWidth,
//                 ),
//               ),
//               if (exporter.isInitial)
//                 _ExportButton(
//                   diameter: sideWidth - loadingStrokeWidth * 2,
//                   onTap: exporter.start,
//                 ),
//               if (exporter.isDone)
//                 TextButton(
//                   onPressed: exporter.openOutputFile,
//                   child: _LargeText('Open'),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _LoadingIndicator extends StatelessWidget {
//   const _LoadingIndicator({
//     Key? key,
//     required this.value,
//     required this.strokeWidth,
//   }) : super(key: key);

//   final double value;
//   final double strokeWidth;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       // Prevent stroke from overflowing widget, as stroke is centered around the widget's edge.
//       padding: EdgeInsets.all(strokeWidth / 2),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Positioned.fill(
//             child: CircularProgressIndicator(
//               value: value,
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 Theme.of(context).colorScheme.primary,
//               ),
//               backgroundColor: Colors.black12,
//               strokeWidth: strokeWidth,
//             ),
//           ),
//           _LargeText(value < 1 ? _formatProgress(value) : ''),
//         ],
//       ),
//     );
//   }

//   String _formatProgress(double value) =>
//       '${(value * 100).toStringAsFixed(0)}%';
// }

// class _LargeText extends StatelessWidget {
//   const _LargeText(this.text, {Key? key}) : super(key: key);

//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: TextStyle(
//         fontSize: 32,
//         fontWeight: FontWeight.bold,
//         color: Colors.white,
//       ),
//     );
//   }
// }

// class _ExportButton extends StatelessWidget {
//   const _ExportButton({
//     Key? key,
//     required this.diameter,
//     this.onTap,
//   }) : super(key: key);

//   final double diameter;
//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     return RaisedButton(
//       color: Theme.of(context).colorScheme.primary,
//       highlightColor: Colors.white12,
//       splashColor: Colors.white,
//       shape: CircleBorder(),
//       onPressed: onTap,
//       child: SizedBox(
//         width: diameter,
//         height: diameter,
//         child: Center(
//           child: Text(
//             'Export video',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               letterSpacing: -0.9,
//               color: Theme.of(context).colorScheme.onPrimary,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
