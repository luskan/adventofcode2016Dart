import 'package:test/test.dart';
import 'package:adventofcode_2016/day03.dart';

void main() {
  test('day03 ...', () async {
    var testData = '''
      5 10 25
    ''';
    expect(Day03().solve(Day03.parseData(testData)), 0);
  });
}
