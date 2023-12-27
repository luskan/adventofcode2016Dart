import 'dart:convert';

import 'package:test/test.dart';
import 'package:adventofcode_2016/day07.dart';

void main() {
  test('day07 ...', () async {
    expect((await Day07().solve(Day07.parseData(LineSplitter().convert("abba[mnop]qrst")))), 1);
    expect((await Day07().solve(Day07.parseData(LineSplitter().convert("abcd[bddb]xyyx")))), 0);
    expect((await Day07().solve(Day07.parseData(LineSplitter().convert("aaaa[qwer]tyui")))), 0);
    expect((await Day07().solve(Day07.parseData(LineSplitter().convert("ioxxoj[asdfgh]zxcvbn")))), 1);

    expect((await Day07().solve(Day07.parseData(LineSplitter().convert("aba[bab]xyz")), part2: true)), 1);
    expect((await Day07().solve(Day07.parseData(LineSplitter().convert("xyx[xyx]xyx")), part2: true)), 0);
    expect((await Day07().solve(Day07.parseData(LineSplitter().convert("aaa[kek]eke")), part2: true)), 1);
    expect((await Day07().solve(Day07.parseData(LineSplitter().convert("zazbz[bzb]cdb")), part2: true)), 1);


  });
}
