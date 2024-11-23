import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:adventofcode_2016/day24.dart';
import 'package:test/test.dart';

void main() {
  test('day24 ...', () async {
var testData = '''
###########
#0.1.....2#
#.#######.#
#4.......3#
###########
''';

  expect(await Day24().solve(Day24.parseData(testData)), 14);
  });
}
