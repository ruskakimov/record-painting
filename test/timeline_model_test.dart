import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mooltik/drawing/data/frame/frame_model.dart';
import 'package:mooltik/editing/data/timeline_model.dart';

const Size _size = Size(1080, 720);

void main() {
  group('TimelineModel', () {
    test('starts with first frame selected', () {
      final timeline = TimelineModel(
        frames: [
          FrameModel(id: 1, size: _size, duration: Duration(seconds: 2)),
          FrameModel(id: 2, size: _size, duration: Duration(seconds: 2)),
        ],
        vsync: TestVSync(),
      );
      expect(timeline.currentFrame.id, 1);
    });

    test('scrubbing updates current frame', () {
      final timeline = TimelineModel(
        frames: [
          FrameModel(id: 1, size: _size, duration: Duration(seconds: 2)),
          FrameModel(id: 2, size: _size, duration: Duration(seconds: 2)),
        ],
        vsync: TestVSync(),
      );
      timeline.scrub(0.5);
      expect(timeline.currentFrame.id, 2);
      timeline.scrub(-0.01);
      expect(timeline.currentFrame.id, 1);
    });

    test('playhead position doesn\'t change when frame duration is changed',
        () {
      final timeline = TimelineModel(
        frames: [
          FrameModel(id: 1, size: _size, duration: Duration(milliseconds: 500)),
          FrameModel(id: 2, size: _size, duration: Duration(milliseconds: 500)),
        ],
        vsync: TestVSync(),
      );
      timeline.scrub(0.25);
      expect(timeline.playheadPosition, Duration(milliseconds: 250));
      timeline.changeFrameDurationAt(0, Duration(milliseconds: 900));
      expect(timeline.playheadPosition, Duration(milliseconds: 250));
      expect(timeline.currentFrame.id, 1);
    });

    test('handles frame duration change past playhead (from right to left)',
        () {
      final timeline = TimelineModel(
        frames: [
          FrameModel(id: 1, size: _size, duration: Duration(milliseconds: 500)),
          FrameModel(id: 2, size: _size, duration: Duration(milliseconds: 500)),
        ],
        vsync: TestVSync(),
      );
      timeline.scrub(0.25);
      expect(timeline.playheadPosition, Duration(milliseconds: 250));
      timeline.changeFrameDurationAt(0, Duration(milliseconds: 200));
      expect(timeline.playheadPosition, Duration(milliseconds: 250));
      expect(timeline.currentFrame.id, 2);
    });

    test('handles deleting before current frame', () {
      final timeline = TimelineModel(
        frames: [
          FrameModel(id: 1, size: _size, duration: Duration(seconds: 1)),
          FrameModel(id: 2, size: _size, duration: Duration(seconds: 2)),
          FrameModel(id: 3, size: _size, duration: Duration(seconds: 10)),
          FrameModel(id: 4, size: _size, duration: Duration(seconds: 4)),
          FrameModel(id: 5, size: _size, duration: Duration(seconds: 7)),
        ],
        vsync: TestVSync(),
      );
      expect(timeline.totalDuration, Duration(seconds: 24));
      timeline.scrub(0.5);
      expect(timeline.playheadPosition, Duration(seconds: 12));
      expect(timeline.currentFrame.id, 3);
      expect(timeline.currentFrameStartTime, Duration(seconds: 3));
      timeline.deleteFrameAt(1);
      expect(timeline.totalDuration, Duration(seconds: 22));
      expect(timeline.playheadPosition, Duration(seconds: 10));
      expect(timeline.currentFrame.id, 3);
      expect(timeline.currentFrameStartTime, Duration(seconds: 1));
    });

    test('handles deleting current frame', () {
      final timeline = TimelineModel(
        frames: [
          FrameModel(id: 1, size: _size, duration: Duration(milliseconds: 500)),
          FrameModel(id: 2, size: _size, duration: Duration(milliseconds: 500)),
        ],
        vsync: TestVSync(),
      );
    });

    test('handles deleting after current frame', () {
      final timeline = TimelineModel(
        frames: [
          FrameModel(id: 1, size: _size, duration: Duration(milliseconds: 500)),
          FrameModel(id: 2, size: _size, duration: Duration(milliseconds: 500)),
        ],
        vsync: TestVSync(),
      );
    });
  });
}
