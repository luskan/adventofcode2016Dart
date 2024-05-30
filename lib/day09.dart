import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';

class Day09 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return  parseData(File(filePath).readAsStringSync());
  }

  static dynamic parseData(String line) {
    return line;
  }

  int countUncompressedData(String data, {var part2 = false}) {
    var result = 0;
    var rgRule = RegExp(r"\((?<span>\d+)+x(?<count>\d+)\)");

    for (var n = 0; n < data.length; n++) {
      String c = data[n];
      if (c == '(') {
        var ne = n + 1;
        while(data[ne] != ')') ne++;

        String extracted = data.substring(n, ne+1);
        var match = rgRule.firstMatch(extracted)!;
        var span = int.tryParse(match.namedGroup("span")!)!;
        var count = int.tryParse(match.namedGroup("count")!)!;
        String spanData = data.substring(ne+1, ne + span + 1);
        if (part2)
          result += count * countUncompressedData(spanData, part2: part2);
        else
          result += count * spanData.length;
        n = ne + span;
      }
      else {
        result += 1;
      }
    }

    return result;
  }

  solve(String data, {var part2 = false}) async {
    return countUncompressedData(data, part2: part2);
  }

  @override
  Future<void> run() async {
    print("Day09");

    var data = readData("../adventofcode_input/2016/data/day09.txt");

    var res1 = await solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day09_result.txt", 0));

    var res2 = await solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day09_result.txt", 1));
  }
}