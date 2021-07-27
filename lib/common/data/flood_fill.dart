import 'dart:collection';
import 'dart:typed_data';

/// Fills image represented by [imageBytes], [imageWidth], and [imageHeight]
/// with the given [color]
/// starting at [startX], [startY].
ByteData floodFill(
  ByteData imageBytes,
  int imageWidth,
  int imageHeight,
  int startX,
  int startY,
  int color,
) {
  final image = _Image(imageBytes, imageWidth, imageHeight);

  final oldColor = image.getPixel(startX, startY);

  // Prevent infinite loop. Not neccessary when filled area is written to an empty image.
  if (_closeEnough(oldColor, color)) return imageBytes;

  final q = Queue<List<int>>();
  q.add([startX, startY]);

  int x1;
  bool spanAbove, spanBelow;

  bool shouldFill(int x, int y) {
    return _closeEnough(image.getPixel(x, y), oldColor);
  }

  while (q.isNotEmpty) {
    final coord = q.removeFirst();
    final x = coord[0];
    final y = coord[1];

    x1 = x;
    while (x1 >= 0 && shouldFill(x1, y)) x1--;
    x1++;
    spanAbove = spanBelow = false;
    while (x1 < image.width && shouldFill(x1, y)) {
      image.setPixel(x1, y, color);

      if (!spanAbove && y > 0 && shouldFill(x1, y - 1)) {
        q.add([x1, y - 1]);
        spanAbove = true;
      } else if (spanAbove && y > 0 && shouldFill(x1, y - 1)) {
        spanAbove = false;
      }
      if (!spanBelow && y < image.height - 1 && shouldFill(x1, y + 1)) {
        q.add([x1, y + 1]);
        spanBelow = true;
      } else if (spanBelow && y < image.height - 1 && shouldFill(x1, y + 1)) {
        spanBelow = false;
      }
      x1++;
    }
  }

  return image.bytes;
}

bool _closeEnough(int colorA, int colorB) {
  return (colorA - colorB).abs() < 5;
}

class _Image {
  _Image(this.bytes, this.width, this.height);

  final ByteData bytes;
  final int width;
  final int height;

  bool withinBounds(int x, int y) {
    return x >= 0 && x < width && y >= 0 && y < height;
  }

  int _byteOffset(int x, int y) => (y * width + x) * 4;

  int getPixel(int x, int y) {
    return bytes.getUint32(_byteOffset(x, y));
  }

  void setPixel(int x, int y, int color) {
    return bytes.setUint32(_byteOffset(x, y), color);
  }
}
