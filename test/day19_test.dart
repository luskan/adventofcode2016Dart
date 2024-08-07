import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:adventofcode_2016/day19.dart';
import 'package:test/test.dart';

void main() {
  test('day19 ...', () async {
    expect(await Day19().solve(5) == 3, true);
    expect(await Day19().solve(5, part2: true) == 2, true);
  });
}
