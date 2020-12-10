import 'package:flutter/material.dart';
import 'package:mooltik/editor/frame/frame_model.dart';

class TimelineModel extends ChangeNotifier {
  TimelineModel({
    @required this.frames,
    TickerProvider vsync,
  })  : assert(frames != null && frames.isNotEmpty),
        _selectedFrameIndex = 0,
        _selectedFrameStart = Duration.zero,
        _selectedFrameEnd = frames.first.duration,
        _controller = AnimationController(
          vsync: vsync,
          duration: frames.fold(
            Duration.zero,
            (duration, frame) => duration + frame.duration,
          ),
        );

  final List<FrameModel> frames;
  final AnimationController _controller;

  Duration get playheadPosition => totalDuration * _controller.value;

  Duration get totalDuration => _controller.duration;

  FrameModel get selectedFrame => frames[_selectedFrameIndex];

  int get selectedFrameIndex => _selectedFrameIndex;
  int _selectedFrameIndex;

  double get selectedFrameProgress =>
      (playheadPosition - _selectedFrameStart).inMilliseconds /
      selectedFrame.duration.inMilliseconds;

  Duration _selectedFrameStart;
  Duration _selectedFrameEnd;

  void _updateSelectedFrame() {
    if (playheadPosition < _selectedFrameStart) {
      _selectPrevFrame();
    } else if (playheadPosition > _selectedFrameEnd) {
      _selectNextFrame();
    }
  }

  void _selectPrevFrame() {
    if (_selectedFrameIndex == 0) return;
    _selectedFrameIndex--;
    _selectedFrameEnd = _selectedFrameStart;
    _selectedFrameStart -= selectedFrame.duration;
  }

  void _selectNextFrame() {
    if (_selectedFrameIndex == frames.length - 1) return;
    _selectedFrameIndex++;
    _selectedFrameStart = _selectedFrameEnd;
    _selectedFrameEnd += selectedFrame.duration;
  }

  /// Scrubs the timeline by a [fraction] of total duration.
  void scrub(double fraction) {
    _controller.value += fraction;
    _updateSelectedFrame();
    notifyListeners();
  }
}