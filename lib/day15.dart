import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';

class Disc {
  final int disc;
  final int positions;
  final int zeroTime;
  final int startTime;

  int currentPosition = 0;

  Disc({required this.disc, required this.positions, required this.zeroTime, required this.startTime});
}

class Day15 extends Day with ProblemReader, SolutionCheck {

  static String readData(var filePath) {
    var data = File(filePath).readAsStringSync();
    return data;
  }

  static List<Disc> parseData(var data) {

    /*
    Disc #1 has 5 positions; at time=0, it is at position 4.
    Disc #2 has 2 positions; at time=0, it is at position 1.
    */
    var rg = RegExp(r'^Disc #(?<disc>\d+) has (?<positions>\d+) positions; at time=(?<zero_time>\d+), it is at position (?<start_time>\d+).$');
    var discs = <Disc>[];
    for (var line in LineSplitter().convert(data)) {
      var m = rg.firstMatch(line);
      var disc = Disc(
        disc: int.parse(m?.namedGroup("disc") ?? "0"),
        positions: int.parse(m?.namedGroup("positions") ?? "0"),
        zeroTime: int.parse(m?.namedGroup("zero_time") ?? "0"),
        startTime: int.parse(m?.namedGroup("start_time") ?? "0")
      );
      discs.add(disc);
    }
    return discs;
  }

  Future<int> solve(List<Disc> discs, {var part2 = false}) async {
    var t = 0;

    if (part2) {
      discs.add(Disc(disc: discs.length + 1, positions: 11, zeroTime: 0, startTime: 0 ));
    }

    while (true) {
      var success = true;
      for (var disc in discs) {
        var pos = (disc.startTime + disc.disc + t) % disc.positions;
        if (pos != 0) {
          success = false;
          break;
        }
      }
      if (success) {
        return t;
      }
      t++;
    }
  }

  @override
  Future<void> run() async {
    print("Day15");

    var data = readData("../adventofcode_input/2016/data/day15.txt");

    var res1 = await solve(parseData(data));
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day15_results.txt", 0));

    var res2 = await solve(parseData(data), part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day15_results.txt", 1));
  }
}