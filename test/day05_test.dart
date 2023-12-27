@Timeout(Duration(seconds: 1120))

import 'package:test/test.dart';
import 'package:adventofcode_2016/day05.dart';

void main() {
  test('day05 ...', () async {
    expect((await Day05().solve(Day05.parseData("abc"))).startsWith("18f47a30"), true);
  });
  test('day05 b ...', () async {
    expect((await Day05().solve(Day05.parseData("abc"), part2:true)).startsWith("05ace8e3"), true);
  });
}