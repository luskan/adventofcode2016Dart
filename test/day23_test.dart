import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:adventofcode_2016/day23.dart';
import 'package:test/test.dart';

void main() {
  test('day23 ...', () async {
    var testData = '''
cpy 2 a
tgl a
tgl a
tgl a
cpy 1 a
dec a
dec a
''';
    expect(await Day23().solve(Day23.parseData(testData)), 3);
  });
}
