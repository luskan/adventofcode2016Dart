import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:adventofcode_2016/day20.dart';
import 'package:test/test.dart';

void main() {
  test('day20 ...', () async {
    expect(await Day20().solve("10000") == 0, true);
  });
}
