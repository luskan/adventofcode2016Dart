import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:adventofcode_2016/day21.dart';
import 'package:test/test.dart';

void main() {
  test('day21 ...', () async {

    var testInput = '''
swap position 4 with position 0
swap letter d with letter b
reverse positions 0 through 4
rotate left 1 step
move position 1 to position 4
move position 3 to position 0
rotate based on position of letter b
rotate based on position of letter d
''';
    expect(await Day21().solve(testInput, "abcde") == "decab", true);
    expect(await Day21().solve(testInput, "decab", part2: true) == "abcde", true);
  });
}
