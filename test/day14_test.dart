import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:test/test.dart';
import 'package:adventofcode_2016/day14.dart';

void main() {
  test('day14 ...', () async {
    expect(await Day14().solve("abc") == 22728, true);
    expect(await Day14().solve("abc", part2: true) == 22551, true);
  });
}
