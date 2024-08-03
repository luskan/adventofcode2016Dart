import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:adventofcode_2016/day25.dart';
import 'package:test/test.dart';

void main() {
  test('day25 ...', () async {
    expect(await Day25().solve("10000") == 0, true);
  });
}
