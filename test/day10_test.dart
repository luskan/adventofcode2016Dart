import 'dart:convert';

import 'package:test/test.dart';
import 'package:adventofcode_2016/day10.dart';

void main() {
  test('day10 ...', () async {
    var testData = '''
value 5 goes to bot 2
bot 2 gives low to bot 1 and high to bot 0
value 3 goes to bot 1
bot 1 gives low to output 1 and high to bot 0
bot 0 gives low to output 2 and high to output 0
value 2 goes to bot 2    
    ''';
    expect(await Day10().solve(Day10.parseData(testData), 5, 2), 2);
  });
}
