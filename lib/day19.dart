import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';

class Day19 extends Day with ProblemReader, SolutionCheck {

  static String readData(var filePath) {
    var data = File(filePath).readAsStringSync();
    return data;
  }

  static int parseData(String data) {
    return int.parse(data);
  }

  Future<int> solve(int data, {var part2 = false}) async {

    if (part2) {
      return solvePart2(data);
    }

    // josephus problem solution(n):
    int pos = 0;
    for (var i = 2; i <= data; i++) {
      pos = (pos + 2) % i;
    }
    return pos + 1;
  }

  int solvePart2(int n) {
    // Keep reference to middle elve and remove it from list on each iteration
    // Make sure to adhere to the rule to use the left one if there are two middle ones.

    // Its O(n) - executes in around 0.5s for n = 3014387
    DoubleLinkedQueue<int> elves = DoubleLinkedQueue<int>.from(List<int>.generate(n, (index) => index + 1));
    DoubleLinkedQueueEntry<int> middle = elves.firstEntry()!;
    while (middle.element != n~/2+1) {
      middle = middle.nextEntry()!;
    }

    while (elves.length > 1) {

      var tmp = middle.nextEntry() == null ? elves.firstEntry() : middle.nextEntry();
      middle.remove();
      middle = tmp!;
      if (elves.length % 2 == 0) {
        if (middle.nextEntry() != null)
          middle = middle.nextEntry()!;
        else
          middle = elves.firstEntry()!;
      }
    }

    return elves.first;
  }


  @override
  Future<void> run() async {
    print("Day19");

    var data = readData("../adventofcode_input/2016/data/day19.txt");

    var res1 = await solve(parseData(data));
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day19_results.txt", 0));

    var res2 = await solve(parseData(data), part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day19_results.txt", 1));
  }
}