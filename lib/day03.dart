import 'dart:convert';
import 'dart:io';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

//@WorkingOnDayTag()
@DayTag()
class Day03 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static dynamic parseData(var data) {
    String regMatch = r'^\s*(\d+)\s*(\d+)\s*(\d+)\s*$';
    RegExp rg = RegExp(regMatch);
    return LineSplitter()
        .convert(data)
        .map((e) => e.trim())
        .where((value) => value.isNotEmpty)
        .map((e) {
          var matches = rg.allMatches(e);
          var m = matches.elementAt(0);
          var d1 = m.group(1);
          var d2 = m.group(2);
          var d3 = m.group(3);
          return [int.parse(d1!), int.parse(d2!), int.parse(d3!)];
        })
        .toList();
  }

  int solve(var data, {var part2 = false}) {

    if (part2) {
      var arr2 = [];
      for (var n = 0; n + 2 < data.length; n+=3) {
        arr2.add([data[n+0][0], data[n+1][0], data[n+2][0]]);
        arr2.add([data[n+0][1], data[n+1][1], data[n+2][1]]);
        arr2.add([data[n+0][2], data[n+1][2], data[n+2][2]]);
      }
      data = arr2;
    }

    var total = 0;
    for (var el in data) {
      if (el[0] + el[1] > el[2]
       && el[0] + el[2] > el[1]
       && el[1] + el[2] > el[0]) {
        total++;
      }
    }
    return total;
  }

  @override
  Future<void> run() async {
    print("Day03");

    var data = readData("../adventofcode_input/2016/data/day03.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day03_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day03_result.txt", 1));
  }
}
