import 'package:flutter/material.dart';
import 'package:mooltik/editing/data/timeline_view_model.dart';
import 'package:provider/provider.dart';

typedef TimelinePositionedDragUpdate(Duration updatedTimestamp);

class TimelinePositioned extends StatefulWidget {
  const TimelinePositioned({
    Key key,
    @required this.timestamp,
    @required this.y,
    @required this.width,
    @required this.height,
    @required this.child,
    this.onDragUpdate,
  }) : super(key: key);

  /// Timeline timestamp. Determines center of horizontal position.
  final Duration timestamp;

  /// Timeline vertical offset from top. Determines center of vertical position.
  final double y;

  /// Child width.
  final double width;

  /// Child height.
  final double height;

  final Widget child;

  final TimelinePositionedDragUpdate onDragUpdate;

  @override
  _TimelinePositionedState createState() => _TimelinePositionedState();
}

class _TimelinePositionedState extends State<TimelinePositioned> {
  Offset _dragStartOffset;

  @override
  Widget build(BuildContext context) {
    final timelineView = context.watch<TimelineViewModel>();

    final offset = Offset(
      timelineView.xFromTime(widget.timestamp) - widget.width / 2,
      widget.y - widget.height / 2,
    );

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: widget.onDragUpdate != null
            ? (details) {
                _dragStartOffset = offset;
              }
            : null,
        onHorizontalDragUpdate: widget.onDragUpdate != null
            ? (details) {
                final timelinePosition =
                    details.localPosition + _dragStartOffset;
                final updatedTimestamp =
                    timelineView.timeFromX(timelinePosition.dx);
                widget.onDragUpdate(updatedTimestamp);
              }
            : null,
        child: widget.child,
      ),
    );
  }
}
