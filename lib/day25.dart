import 'dart:async';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';

class Day25 extends Day with ProblemReader, SolutionCheck {

  static String readData(var filePath) {
    var data = File(filePath).readAsStringSync();
    return data;
  }

  static dynamic parseData(var data) {
    return data;
  }

  Future<int> solve(dynamic data, {var part2 = false}) async {
    return 0;
  }

  @override
  Future<void> run() async {
    print("Day25");

    var data = readData("../adventofcode_input/2016/data/day25.txt");

    var res1 = await solve(data);
    print('Part1: $res1');
    verifyResult(res1, getStringFromFile("../adventofcode_input/2016/data/day25_results.txt", 0));

    var res2 = await solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day25_results.txt", 1));
  }
}