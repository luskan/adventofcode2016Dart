import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:adventofcode_2016/day21.dart';
import 'package:test/test.dart';

void main() {
  test('day21 ...', () async {
    expect(await Day21().solve("10000") == 0, true);
  });
}
