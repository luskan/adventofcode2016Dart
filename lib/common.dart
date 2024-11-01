import 'dart:convert';
import 'dart:io';

final int maxInt = (double.infinity is int) ? double.infinity as int : ~minInt;
final int minInt =
    (double.infinity is int) ? -double.infinity as int : (-1 << 63);

int getIntFromFile(String s, int i) {
  return int.parse(LineSplitter().convert(File(s).readAsStringSync())[i]);
}

String getStringFromFile(String s, int start, {int end = -1}) {
  var res = "";
  var list = LineSplitter().convert(File(s).readAsStringSync());
  if (end == -1) {
    end = start + 1;
  }
  for (var i = start; i < end; ++i) {
    if (i > start) {
      res += "\n";
    }
    res += list[i];
  }
  return res;
}

class Point {
  final int x, y;

  Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

(double width, double height) calculateTextExtent(
  dynamic text,
  dynamic font, {
  double scale = 1.0,
  double letterSpacing = 0,
  double lineHeight = 1.0,
}) {
  // Convert input to string if it's not already a string
  String textString = text.toString();

  if (textString.isEmpty) return (0, 0);

  double stringWidth = 0;
  double stringHeight = 0;

  final chars = textString.codeUnits;
  for (var c in chars) {
    if (!font.characters.containsKey(c)) {
      continue;
    }

    final ch = font.characters[c]!;

    // Calculate width
    stringWidth += (ch.xadvance * scale);

    // Add letter spacing (except after the last character)
    if (c != chars.last) {
      stringWidth += letterSpacing;
    }

    // Calculate height
    double characterHeight = (ch.height + ch.yoffset) * scale * lineHeight;

    // Update max height if current character is taller
    if (characterHeight > stringHeight) {
      stringHeight = characterHeight;
    }
  }

  return (stringWidth, stringHeight);
}
