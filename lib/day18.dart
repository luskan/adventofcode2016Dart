import 'dart:async';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';

class Day18 extends Day with ProblemReader, SolutionCheck {

  static String readData(var filePath) {
    var data = File(filePath).readAsStringSync();
    return data;
  }

  static dynamic parseData(var data) {
    return data;
  }

  Future<int> solve(String data, int rows, {var part2 = false}) async {

    int safeFields = data.split("").where((element) => element == ".").length;

    for (var i = 0; i < rows-1; i++) {
      var row = data;
      var newRow = "";
      for (var j = 0; j < row.length; j++) {
        var left = j == 0 ? "." : row[j - 1];
        var center = row[j];
        var right = j == row.length - 1 ? "." : row[j + 1];
        if (left == "^" && center == "^" && right == ".") {
          newRow += "^";
        } else if (left == "." && center == "^" && right == "^") {
          newRow += "^";
        } else if (left == "^" && center == "." && right == ".") {
          newRow += "^";
        } else if (left == "." && center == "." && right == "^") {
          newRow += "^";
        } else {
          newRow += ".";
        }
      }
      data = newRow;
      safeFields += data.split("").where((element) => element == ".").length;
    }

    return safeFields;
  }

  @override
  Future<void> run() async {
    print("Day18");

    var data = readData("../adventofcode_input/2016/data/day18.txt");

    var res1 = await solve(data, 40);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day18_results.txt", 0));

    var res2 = await solve(data, 400000, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day18_results.txt", 1));
  }
}