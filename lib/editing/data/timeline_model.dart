import 'package:flutter/material.dart';
import 'package:mooltik/common/data/project/scene_model.dart';
import 'package:mooltik/common/data/sequence/sequence.dart';
import 'package:mooltik/drawing/data/frame/frame_model.dart';

class TimelineModel extends ChangeNotifier {
  TimelineModel({
    @required this.sceneSeq,
    @required TickerProvider vsync,
  })  : assert(sceneSeq != null && sceneSeq.length > 0),
        _playheadController = AnimationController(
          vsync: vsync,
          duration: sceneSeq.totalDuration,
        ) {
    _playheadController.addListener(() {
      sceneSeq.playhead = Duration(
        milliseconds:
            (sceneSeq.totalDuration * _playheadController.value).inMilliseconds,
      );
      notifyListeners();
    });
    sceneSeq.addListener(notifyListeners);
  }

  final Sequence<SceneModel> sceneSeq;
  final AnimationController _playheadController;

  Duration get playheadPosition => sceneSeq.playhead;

  bool get isPlaying => _playheadController.isAnimating;

  Duration get totalDuration => sceneSeq.totalDuration;

  SceneModel get currentScene => sceneSeq.current;

  FrameModel get currentFrame =>
      currentScene.frameAt(playheadPosition - sceneSeq.currentSpanStart);

  /// Jumps to a new playhead position.
  void jumpTo(Duration playheadPosition) {
    sceneSeq.playhead = playheadPosition;
    notifyListeners();
  }

  /// Moves playhead by [diff].
  void scrub(Duration diff) {
    if (isPlaying) {
      _playheadController.stop();
    }
    sceneSeq.playhead += diff;
    notifyListeners();
  }

  /// Reset playhead to the beginning.
  void reset() {
    sceneSeq.playhead = Duration.zero;
    notifyListeners();
  }

  void play() {
    _playheadController.duration = totalDuration;
    _playheadController.value =
        playheadPosition.inMicroseconds / totalDuration.inMicroseconds;
    _playheadController.forward();
    notifyListeners();
  }

  void pause() {
    _playheadController.stop();
    notifyListeners();
  }
}
