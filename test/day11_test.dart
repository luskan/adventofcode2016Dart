import 'dart:convert';

import 'package:test/test.dart';
import 'package:adventofcode_2016/day11.dart';

void main() {
  test('day11 ...', () async {
    var testData = '''
The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
The second floor contains a hydrogen generator.
The third floor contains a lithium generator.
The fourth floor contains nothing relevant.
    ''';
    expect(await Day11().solve(Day11.parseData(testData)), 11);
  });
}
