import 'dart:convert';

import 'package:test/test.dart';
import 'package:adventofcode_2016/day12.dart';

void main() {
  test('day12 ...', () async {
    var testData = '''
cpy 41 a
inc a
inc a
dec a
jnz a 2
dec a
''';
    expect(await Day12().solve(Day12.parseData(testData)), 42);
  });
}
