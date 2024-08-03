import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:adventofcode_2016/day18.dart';
import 'package:test/test.dart';

void main() {
  test('day18 ...', () async {
    expect(await Day18().solve(".^^.^.^^^^", 10) == 38, true);
  });
}
