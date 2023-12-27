import 'package:test/test.dart';
import 'package:adventofcode_2016/day02.dart';

void main() {
  test('day02 ...', () async {
    var testData = '''
      ULL
      RRDDD
      LURDL
      UUUUD
    ''';
    expect(Day02().solve(Day02.parseData(testData)), "1985");
    expect(Day02().solve(Day02.parseData(testData), part2: true), "5DB3");
  });
}
