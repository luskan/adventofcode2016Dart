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
    final rgRotate = RegExp(r"rotate (?<rc>row|column) (x|y)=(?<y>\d+) by (?<by>\d+)");
    return lines.map(
        (line) {
          var m = rgRect.firstMatch(line);
          if (m != null) {
            return {
              'type': 'rect',
              'width': int.parse(m.namedGroup('width')!),
              'height': int.parse(m.namedGroup('height')!),
            };
          }
          m = rgRotate.firstMatch(line);
          if (m != null) {
            return {
              'type': m.namedGroup("rc")! == "row" ? 'rotate_row' : 'rotate_column',
              'cord': int.parse(m.namedGroup('y')!),
              'by': int.parse(m.namedGroup('by')!),
            };
          }
          assert(false);
          return null;
        }
    ).where((element) => element != null).toList();
  }

  solve(var data, {var part2 = false}) async {
    var count = 0;
    Map<Point, bool> screen = {};
    int screenWidth = 50;
    int screenHeight = 6;
    for (var op in data) {
     switch(op['type']) {
       case "rect":
         fillRect(screen, screenWidth, screenHeight, op['width'], op['height']);
         break;
       case "rotate_column":
         rotateColumn(screen, screenWidth, screenHeight, op['cord'], op['by']);
         break;
       case "rotate_row":
         rotateRow(screen, screenWidth, screenHeight, op['cord'], op['by']);
         break;
     }
    }

    for(var y = 0; y < screenHeight; ++y) {
      var log = "";
      for(var x = 0; x < screenWidth; ++x) {
        log += screen[Point(x, y)]??false ? "X" : " ";
      }
      print(log);
    }

    return screen.values.toList().fold<int>(0,
            (previousValue, element) => element ? previousValue+1:previousValue);
  }


  @override
  Future<void> run() async {
    print("Day08");

    var data = readData("../adventofcode_input/2016/data/day08.txt");

    var res1 = await solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day08_result.txt", 0));

    // For part2 see what was printed during part 1, for example:
    //
    // XXXX   XX X  X XXX  X  X  XX  XXX  X    X   X  XX
    //    X    X X  X X  X X X  X  X X  X X    X   X   X
    //   X     X XXXX X  X XX   X    X  X X     X X    X
    //  X      X X  X XXX  X X  X    XXX  X      X     X
    // X    X  X X  X X X  X X  X  X X    X      X  X  X
    // XXXX  XX  X  X X  X X  X  XX  X    XXXX   X   XX
    //
    // ZJHRKCPLYJ
  }

  void fillRect(Map<Point, bool> screen, int maxWidth, int maxHeight, int width, int height) {
    for (var x = 0; x < width; ++x) {
      for (var y = 0; y < height; ++y) {
        screen[Point(x,y)] = true;
      }
    }
  }

  // Rotates column at x by y positions,
  void rotateColumn(Map<Point, bool> screen, int maxWidth, int maxHeight, int cord, int by) {
    Map<Point, bool> copy = {};

    // Create a new state for the column
    for (var entry in screen.entries) {
      if (entry.key.x == cord) {
        int newY = (entry.key.y + by) % maxHeight;
        copy[Point(cord, newY)] = entry.value;
        screen[entry.key] = false;
      }
    }

    // Update screen with new column values
    for (var entry in copy.entries) {
      screen[entry.key] = entry.value;
    }
  }

  void rotateRow(Map<Point, bool> screen, int maxWidth, int maxHeight, int cord, int by) {
    Map<Point, bool> copy = {};
    for (var entry in screen.entries) {
      if (entry.key.y == cord) {
        int newX = (entry.key.x + by) % maxWidth;
        copy[Point(newX, cord)] = entry.value;
        screen[entry.key] = false;
      }
    }
    for (var entry in copy.entries) {
      screen[entry.key] = entry.value;
    }
  }

}