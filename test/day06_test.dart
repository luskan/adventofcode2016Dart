import 'dart:convert';

import 'package:test/test.dart';
import 'package:adventofcode_2016/day06.dart';

void main() {
  test('day06 ...', () async {
    var testData = '''eedadn
drvtee
eandsr
raavrd
atevrs
tsrnev
sdttsa
rasrtv
nssdts
ntnada
svetve
tesnvt
vntsnd
vrdear
dvrsen
enarar''';
    expect((await Day06().solve(Day06.parseData(LineSplitter().convert(testData)))).startsWith("easter"), true);
    expect((await Day06().solve(Day06.parseData(LineSplitter().convert(testData)), part2: true)).startsWith("advent"), true);
  });
}
