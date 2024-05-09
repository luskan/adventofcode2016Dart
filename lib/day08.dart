import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';

class Day08 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return  parseData(File(filePath).readAsLinesSync());
  }

  static dynamic parseData(List<String> lines) {
    final rgRect = RegExp(r"rect (?<width>\d+)x(?<height>\d+)");
    final rgRotateRow = RegExp(r"rotate row y=\d+ by \d+");
    final rgRotateCol = RegExp(r"rotate column y=\d+ by \d+");
    return lines.map(
        (line) {
          rg
        }
    );
  }

  solve(List<List<dynamic>> data, {var part2 = false}) async {
    var count = 0;

    return count;
  }


  @override
  Future<void> run() async {
    print("Day08");

    var data = readData("../adventofcode_input/2016/data/day08.txt");

    var res1 = await solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day08_result.txt", 0));

    var res2 = await solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day08_result.txt", 1));
  }
}