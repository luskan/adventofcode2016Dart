import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:adventofcode_2016/day16.dart';
import 'package:test/test.dart';
import 'package:adventofcode_2016/day15.dart';

void main() {
  test('day16 ...', () async {
    expect(await Day16().solve("10000", 20) == "01100", true);
  });
}
