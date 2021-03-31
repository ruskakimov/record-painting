import 'package:flutter_test/flutter_test.dart';
import 'package:mooltik/common/data/sequence/sequence.dart';
import 'package:mooltik/common/data/sequence/time_span.dart';

class TestSpan extends TimeSpan {
  TestSpan(this.duration);

  final Duration duration;
}

void main() {
  group('Sequence', () {
    test('playhead starts at zero', () {
      final seq = Sequence([
        TestSpan(Duration(seconds: 1)),
        TestSpan(Duration(seconds: 2)),
      ]);
      expect(seq.playhead, Duration.zero);
    });

    test('handles one span', () {
      final seq = Sequence([TestSpan(Duration(milliseconds: 200))]);
      expect(seq.totalDuration, Duration(milliseconds: 200));
    });

    test('calculates correct total', () {
      final seq = Sequence([
        TestSpan(Duration(milliseconds: 250)),
        TestSpan(Duration(milliseconds: 750)),
        TestSpan(Duration(seconds: 12)),
        TestSpan(Duration(milliseconds: 24)),
      ]);
      expect(
        seq.totalDuration,
        Duration(seconds: 13, milliseconds: 24),
      );
    });

    test('handles iteration', () {
      final list = [
        TestSpan(Duration(milliseconds: 111)),
        TestSpan(Duration(milliseconds: 333)),
        TestSpan(Duration(milliseconds: 555)),
      ];
      final seq = Sequence(list);

      for (int i = 0; i < seq.length; i++) {
        expect(seq[i], list[i]);
      }
    });

    test('ignores later mutations of provided list', () {
      final list = [
        TestSpan(Duration(milliseconds: 111)),
        TestSpan(Duration(milliseconds: 333)),
        TestSpan(Duration(milliseconds: 555)),
      ];
      final seq = Sequence(list);
      list.removeLast();
      expect(seq.length, 3);
    });

    test('syncs playhead with current span', () {
      final seq = Sequence([
        TestSpan(Duration(seconds: 1)),
        TestSpan(Duration(seconds: 2)),
        TestSpan(Duration(milliseconds: 200)),
      ]);
      expect(seq.playhead, Duration.zero);
      expect(seq.currentIndex, 0);
      seq.playhead = Duration(seconds: 1, milliseconds: 400);
      expect(seq.currentIndex, 1);
      seq.playhead = Duration(seconds: 3, milliseconds: 100);
      expect(seq.currentIndex, 2);
    });
  });
}
