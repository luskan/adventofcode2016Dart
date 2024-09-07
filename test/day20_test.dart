import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:adventofcode_2016/day20.dart';
import 'package:test/test.dart';

void main() {
  test('day20 ...', () async {
    var testInput = '''
5-8
0-2
4-7
''';

    expect(await Day20().solve(Day20.parseData(testInput), 0, 9) == 3, true);
  });
}
