import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';
import 'package:crypto/crypto.dart';

import 'package:collection/collection.dart';

class QueueElement {
  String path;
  Point pt;
  Point prevNode = Point(0, 0);
  QueueElement(this.path, this.pt, this.prevNode);
}

class Day17 extends Day with ProblemReader, SolutionCheck {

  static String readData(var filePath) {
    var data = File(filePath).readAsStringSync();
    return data;
  }

  static dynamic parseData(var data) {
    return data;
  }

  String getHashKey(String input) {
    var hash = md5.convert(utf8.encode(input)).toString();
    return hash;
  }

  // BFS search
  Future<String> solve(dynamic key, {var part2 = false}) async {
    var unvisited = Queue<QueueElement>();

    var q = QueueElement("", Point(0, 0), Point(0, 0));
    unvisited.add(q);
    var maxDist = minInt; // for part2
    var maxDistPath = "";

    while (!unvisited.isEmpty) {
      var element = unvisited.removeFirst();
      var pt = element.pt;
      var path = element.path;
      var hash = getHashKey(key + path);
      var doors = hash.substring(0, 4);
      var x = pt.x;
      var y = pt.y;
      if (pt == Point(3, 3)) {

        //print("part2=$part2, ${path.length}, Path: $path");

        if (part2) {
          if (path.length > maxDist) {
            maxDist = path.length;
            maxDistPath = path;
            //print("MaxDist: $maxDist");
          }
          continue;
        }
        else if (!part2)
          return path;
      }

      for (var i = 0; i < 4; ++i) {
        if ("bcdef".contains(doors[i])) {
            QueueElement? q;
            if (i == 0 && y > 0)
              q = QueueElement(path + 'U', Point(x, y - 1), pt);
            else if (i == 1 && y < 3)
              q = QueueElement(path + 'D', Point(x, y + 1), pt);
            else if (i == 2 && x > 0)
              q = QueueElement(path + 'L', Point(x - 1, y), pt);
            else if (i == 3 && x < 3)
              q = QueueElement(path + 'R', Point(x + 1, y), pt);
            if (q != null)
              unvisited.add(q);
        }
      }
    }
    if (part2)
      return maxDistPath;
    assert(false);
    return "";
  }

  @override
  Future<void> run() async {
    print("Day17");

    var data = readData("../adventofcode_input/2016/data/day17.txt");

    var res1 = await solve(data);
    print('Part1: $res1');
    verifyResult(res1, getStringFromFile("../adventofcode_input/2016/data/day17_results.txt", 0));

    var res2 = await solve(data, part2: true);
    print('Part2: ${res2.length}');
    verifyResult(res2.length, getIntFromFile("../adventofcode_input/2016/data/day17_results.txt", 1));
  }
}