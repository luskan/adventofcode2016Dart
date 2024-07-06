import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:test/test.dart';
import 'package:adventofcode_2016/day13.dart';

void main() {
  test('day13 ...', () async {
    expect(await Day13().solve(10, Point(7, 4)) == 11, true);
  });
}
