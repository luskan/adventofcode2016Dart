import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';

class Day06 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return  parseData(File(filePath).readAsLinesSync());
  }

  static parseData(List<String> lines) {
    return lines;
  }

  solve(var data, {var part2 = false}) async {
    var mp = {};
    var result = "";
    for (var c = 0; c < data[0].length; c++) {
      mp.clear();

      for (var r = 0; r < data.length; ++r)
        mp.update(data[r][c], (value) => value+1, ifAbsent: () => 0);

      var maxValue = part2 ? data.length : 0;
      var maxValueChar = "";
      mp.forEach((key, value) {
        if ((part2 && value < maxValue) || (!part2 && value > maxValue)) {
          maxValue = value;
          maxValueChar = key;
        }
      });
      result += maxValueChar;
    }
    return result;
  }

  @override
  Future<void> run() async {
    print("Day06");

    var data = readData("../adventofcode_input/2016/data/day06.txt");

    var res1 = (await solve(data)).substring(0, 8);
    print('Part1: $res1');
    verifyResult(res1, getStringFromFile("../adventofcode_input/2016/data/day06_result.txt", 0));

    var res2 = await solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getStringFromFile("../adventofcode_input/2016/data/day06_result.txt", 1));
  }
}