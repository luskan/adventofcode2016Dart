import 'dart:io';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

@DayTag()
class Day01 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static dynamic parseData(var data) {
    return data.split(',').map((element) {
      element = element.trim();
      var dir = element.substring(0, 1);
      var len = int.parse(element.substring(1));
      return [dir, len];
    }).toList();
  }

  int solve(var data, {var part2 = false}) {
    var current_dir = [0, 1]; // Vector, to the north
    var current_pos = [0, 0];
    var visited_positions = <String>{};
    visited_positions.add("${current_pos[0]}_${current_pos[1]}");
    var done = false;
    for (var el in data) {
      switch (el[0]) {
        case "L":
          current_dir = [-current_dir[1], current_dir[0]];
          break;
        case "R":
          current_dir = [current_dir[1], -current_dir[0]];
          break;
      }

      for (var n = 0; n < el[1]; ++n) {
        current_pos[0] += current_dir[0] as int;
        current_pos[1] += current_dir[1] as int;
        if (part2) {
          var key = "${current_pos[0]}_${current_pos[1]}";
          if (visited_positions.contains(key)) {
            done = true;
            break;
          }
          visited_positions.add(key);
        }
      }
      if (done) break;
    }
    return current_pos[0].abs() + current_pos[1].abs();
  }

  int solve2(var data) {
    return 0;
  }

  @override
  Future<void> run() async {
    print("Day01");

    var data = readData("../adventofcode_input/2016/data/day01.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day01_result.txt", 0));

    var res2 = solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day01_result.txt", 1));
  }
}
