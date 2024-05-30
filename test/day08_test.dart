import 'dart:convert';

import 'package:test/test.dart';
import 'package:adventofcode_2016/day08.dart';

void main() {
  test('day08 ...', () async {

    var testData1 = '''
rect 3x2
rotate column x=1 by 1
rotate row y=0 by 4
rotate column x=1 by 1
''';

    expect((await Day08().solve(Day08.parseData(LineSplitter().convert(testData1)))), 6);

  });
}
