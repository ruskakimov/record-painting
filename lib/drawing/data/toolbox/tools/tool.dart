import 'package:flutter/material.dart';
import 'package:mooltik/drawing/data/frame/stroke.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Tool {
  Tool(this.paint, this.sharedPreferences) : assert(sharedPreferences != null) {
    // Restore selected stroke width.
    if (sharedPreferences.containsKey(strokeWidthKey)) {
      paint.strokeWidth = sharedPreferences.getDouble(strokeWidthKey);
    }

    // Default to middle stroke width option if none selected.
    if (strokeWidthOptions.isNotEmpty &&
        !strokeWidthOptions.contains(paint.strokeWidth)) {
      final midIndex = strokeWidthOptions.length ~/ 2;
      paint.strokeWidth = strokeWidthOptions[midIndex];
    }

    // Restore selected color.
    if (sharedPreferences.containsKey(colorKey)) {
      paint.color = Color(sharedPreferences.getInt(colorKey));
    }
  }

  /// Icon diplayed on the tool's button.
  IconData get icon;

  final Paint paint;
  final SharedPreferences sharedPreferences;

  double get maxStrokeWidth;
  double get minStrokeWidth;

  List<double> get strokeWidthOptions;
  List<Color> get colorOptions => [
        Colors.black,
        Colors.redAccent,
        Colors.yellow,
        Colors.teal,
        Colors.blue,
        Colors.deepPurple,
      ];

  /// Tool name used to prefix shared preferences keys.
  String get name;

  /// Shared preferences key for stroke width.
  String get strokeWidthKey => name + '_stroke_width';

  /// Shared preferences key for color.
  String get colorKey => name + '_color';

  double get strokeWidth => paint.strokeWidth;

  Color get color => paint.color.withOpacity(1);

  double get opacity => paint.color.opacity;

  set strokeWidth(double value) {
    assert(strokeWidth <= maxStrokeWidth && strokeWidth >= minStrokeWidth);
    paint.strokeWidth = value;
    sharedPreferences.setDouble(strokeWidthKey, strokeWidth);
  }

  set color(Color color) {
    paint.color = color.withOpacity(opacity);
    sharedPreferences.setInt(colorKey, paint.color.value);
  }

  set opacity(double value) {
    assert(opacity >= 0 && opacity <= 1);
    paint.color = paint.color.withOpacity(value);
    sharedPreferences.setInt(colorKey, paint.color.value);
  }

  Stroke makeStroke(Offset startPoint);
}
