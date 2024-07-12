import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:test/test.dart';
import 'package:adventofcode_2016/day15.dart';

void main() {
  test('day15 ...', () async {
    var data = '''
Disc #1 has 5 positions; at time=0, it is at position 4.
Disc #2 has 2 positions; at time=0, it is at position 1.
''';
    expect(await Day15().solve(Day15.parseData(data)) == 5, true);
    //expect(await Day15().solve("abc", part2: true) == 22551, true);
  });
}
