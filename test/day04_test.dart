import 'package:test/test.dart';
import 'package:adventofcode_2016/day04.dart';

void main() {
  test('day04 ...', () async {
    var testData = '''
     aaaaa-bbb-z-y-x-123[abxyz]
     a-b-c-d-e-f-g-h-987[abcde]
     not-a-real-room-404[oarel]
     totally-real-room-200[decoy]
    ''';
    expect(Day04().solve(Day04.parseData(testData)), 1514);
    expect(Day04().solve(Day04.parseData("qzmt-zixmtkozy-ivhz-343[zimth]"), part2: true, roomNameToFind: "very encrypted name"), 343);
  });
}
