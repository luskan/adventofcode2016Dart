import 'package:test/test.dart';
import 'package:adventofcode_2016/day01.dart';

void main() {
  test('day01 ...', () async {
    expect(Day01().solve(Day01.parseData("R2, L3")), equals(5));
    expect(Day01().solve(Day01.parseData("R2, R2, R2")), equals(2));
    expect(Day01().solve(Day01.parseData("R5, L5, R5, R3")), equals(12));
    expect(Day01().solve(Day01.parseData("R8, R4, R4, R8"), part2: true),
        equals(4));
  });
}
