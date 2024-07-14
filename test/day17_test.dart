import 'dart:convert';

import 'package:adventofcode_2016/common.dart';
import 'package:adventofcode_2016/day17.dart';
import 'package:test/test.dart';

void main() {
  test('day17 ...', () async {
    expect(await Day17().solve("ihgpwlah") == "DDRRRD", true);
    expect(await Day17().solve("kglvqrro") == "DDUDRLRRUDRD", true);
    expect(await Day17().solve("ulqzkmiv") == "DRURDRUDDLLDLUURRDULRLDUUDDDRR", true);

    var p = await Day17().solve("ihgpwlah", part2: true);
    expect(p.length == 370, true);
    expect((await Day17().solve("kglvqrro", part2: true)).length == 492, true);
    expect((await Day17().solve("ulqzkmiv", part2: true)).length == 830, true);
  });
}
