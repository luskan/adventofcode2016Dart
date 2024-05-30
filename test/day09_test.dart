import 'dart:convert';

import 'package:test/test.dart';
import 'package:adventofcode_2016/day09.dart';

void main() {
  test('day09 ...', () async {
    expect(await Day09().solve(Day09.parseData("ADVENT")), 6);
    expect(await Day09().solve(Day09.parseData("A(1x5)BC")), 7);
    expect(await Day09().solve(Day09.parseData("(3x3)XYZ")), 9);
    expect(await Day09().solve(Day09.parseData("(6x1)(1x3)A")), 6);
    expect(await Day09().solve(Day09.parseData("X(8x2)(3x3)ABCY")), 18);

    expect(await Day09().solve(Day09.parseData("(3x3)XYZ"), part2: true), 9);
    expect(await Day09().solve(Day09.parseData("X(8x2)(3x3)ABCY"), part2: true), 20);
    expect(await Day09().solve(Day09.parseData("(27x12)(20x12)(13x14)(7x10)(1x12)A"), part2: true), 241920);
    expect(await Day09().solve(Day09.parseData("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN"), part2: true), 445);
  });
}
