import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';

class Interval {
  int start;
  int end;

  Interval(this.start, this.end) {
    if (start > end) {
      throw ArgumentError("start must be less than or equal to end");
    }
  }

  @override
  String toString() {
    return 'Interval{start: $start, end: $end}';
  }
}

class Day20 extends Day with ProblemReader, SolutionCheck {

  static String readData(var filePath) {
    var data = File(filePath).readAsStringSync();
    return data;
  }

  static List<Interval> parseData(var data) {
    var rg = RegExp(r'(?<start>\d+)-(?<end>\d+)');
    var intervals = LineSplitter().convert(data)
        .map((e) {
          var m = rg.firstMatch(e);
          var start = int.parse(m?.namedGroup("start") ?? "0");
          var end = int.parse(m?.namedGroup("end") ?? "0");

          return Interval(start, end);
        }).toList();
    return intervals;
  }

  Future<int> solve(List<Interval> intervals, int minValue, int maxValue, {var part2 = false}) async {

    // sort intervals
    intervals.sort((a, b) => a.start.compareTo(b.start));

    // merge intervals
    List<Interval> merged = [];
    var start = intervals[0].start;
    var end = intervals[0].end;
    for (var i = 1; i < intervals.length; i++) {
      if (intervals[i].start <= end + 1) {
        end = max(end, intervals[i].end);
      } else {
        merged.add(Interval(start, end));
        start = intervals[i].start;
        end = intervals[i].end;
      }
    }
    merged.add(Interval(start, end));

    // Collect to list all intervals that are gaps between intervals in merged list
    List<Interval> gaps = [];
    if (merged[0].start > minValue) {
      gaps.add(Interval(minValue, merged[0].start - 1));
    }
    for (var i = 0; i < merged.length - 1; i++) {
      gaps.add(Interval(merged[i].end + 1, merged[i + 1].start - 1));
    }
    if (merged.last.end < maxValue) {
      gaps.add(Interval(merged.last.end + 1, maxValue));
    }

    gaps.sort((a, b) => a.start.compareTo(b.start));

    // Find the lowest number in gaps
    if (part2) {
      return gaps.map((e) => e.end - e.start + 1).reduce((value, element) => value + element);
    }
    else {
      var lowest = gaps.first.start;

      /*
      // brute-force
      for (int v = minValue; v <= maxValue; ++v) {
      if (!intervals.any((element) => element.start <= v && v <= element.end)) {
        lowest = v;
        break;
      }
      }*/

      return lowest;
    }
  }

  @override
  Future<void> run() async {
    print("Day20");

    var data = readData("../adventofcode_input/2016/data/day20.txt");

    var res1 = await solve(parseData(data), 0, 4294967295);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day20_results.txt", 0));

    var res2 = await solve(parseData(data), 0, 4294967295, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day20_results.txt", 1));
  }
}