import 'dart:convert';
import 'dart:io';

import 'package:adventofcode_2016/common.dart';

import 'day.dart';
import 'solution_check.dart';

class PadPos {
  int c;
  int r;
  PadPos(this.c, this.r);

  PadPos.from(PadPos p)
      : c = p.c,
        r = p.r;
}

//@WorkingOnDayTag()
@DayTag()
class Day02 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static dynamic parseData(var data) {
    return LineSplitter()
        .convert(data)
        .map((e) => e.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  var codePad = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9']
  ];

  void part1Move(var dir, var cd) {
    switch (dir) {
      case 'L':
        if (cd.c > 0) cd.c--;
        break;
      case 'R':
        if (cd.c < 2) cd.c++;
        break;
      case 'U':
        if (cd.r > 0) cd.r--;
        break;
      case 'D':
        if (cd.r < 2) cd.r++;
        break;
    }
  }

  var codePadPart2 = [
    ['0','0','0','0','0','0','0'],
    ['0','0','0','1','0','0','0'],
    ['0','0','2','3','4','0','0'],
    ['0','5','6','7','8','9','0'],
    ['0','0','A','B','C','0','0'],
    ['0','0','0','D','0','0','0'],
    ['0','0','0','0','0','0','0'],
  ];

  void part2Move(var dir, var cd) {
    var tmp = PadPos.from(cd);
    switch (dir) {
      case 'L':
        tmp.c--;
        break;
      case 'R':
        tmp.c++;
        break;
      case 'U':
        tmp.r--;
        break;
      case 'D':
        tmp.r++;
        break;
    }
    if (codePadPart2[tmp.r][tmp.c] != '0') {
      cd.r = tmp.r;
      cd.c = tmp.c;
    }
  }

  String solve(var data, {var part2 = false}) {
    var numbers = [];
    data.forEach((dirs) {
      var cd = PadPos.from(numbers.isEmpty ? (part2 ? PadPos(1, 3) : PadPos(1, 1)) : numbers.last);
      dirs.runes.forEach((rune) {
        var dir = String.fromCharCode(rune);
        if (part2) {
          part2Move(dir, cd);
        } else {
          part1Move(dir, cd);
        }
      });
      numbers.add(cd);
    });
    return numbers.fold("", (acc, n) {
      var cc = (part2 ? codePadPart2[n.r][n.c] : codePad[n.r][n.c]);
      return acc + cc;
    });
  }

  @override
  Future<void> run() async {
    print("Day02");

    var data = readData("../adventofcode_input/2016/data/day02.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getStringFromFile("../adventofcode_input/2016/data/day02_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getStringFromFile("../adventofcode_input/2016/data/day02_result.txt", 1));
  }
}
