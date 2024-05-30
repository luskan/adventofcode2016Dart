import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';

typedef ItemType = Map<String, Object>;

class Day10 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return  parseData(File(filePath).readAsStringSync());
  }

  static List<ItemType> parseData(String data) {
    var rgBotGives = RegExp(r"bot (?<bot_id>\d+) gives low to (?<low_who>bot|output) (?<low>\d+) and high to (?<hi_who>bot|output) (?<hi>\d+)");
    var rgBotReceives = RegExp(r"value (?<value>\d+) goes to bot (?<bot_id>\d+)");
    return LineSplitter()
        .convert(data)
        .map((line) => line.trim())
        .where((line) => !line.isEmpty)
        .map((line) {
      ItemType mm = {};
      var m = rgBotGives.firstMatch(line);
      if (m != null) {
        mm["gives"] = true;
        mm["bot_id"] = int.tryParse(m.namedGroup("bot_id")!)!;
        mm["low_who"] = m.namedGroup("low_who")!;
        mm["low"] = int.tryParse(m.namedGroup("low")!)!;
        mm["hi_who"] = m.namedGroup("hi_who")!;
        mm["hi"] = int.tryParse(m.namedGroup("hi")!)!;
      }
      else {
        var m = rgBotReceives.firstMatch(line);
        if (m != null) {
          mm["gives"] = false;
          mm["value"] = int.tryParse(m.namedGroup("value")!)!;
          mm["bot_id"] = int.tryParse(m.namedGroup("bot_id")!)!;
        }
        else {
          assert(false);
        }
      }
      return mm;
    }).toList();
  }

  Future<int> solve(List<ItemType> data, int chip1Compare, int chip2Compare, {var part2 = false}) async {
    Map<int, List<int>> bots = {};
    Map<int, List<int>> outputs = {};
    int resultBotId = -1;

    Queue<ItemType> queue = Queue<ItemType>();
    data.forEach((it) {
        queue.add(it);
    });

    while (!queue.isEmpty) {
      var it = queue.removeFirst();
      var bot_id = it["bot_id"] as int;
      var gives = it["gives"] as bool;
      if (!gives) {
        if (!(bots.containsKey(bot_id)))
          bots[bot_id] = [];
        bots[bot_id]!.add(it["value"] as int);
        bots[bot_id]!.sort();
      }
      else {
        String low_who = it["low_who"] as String;
        int low_id = it["low"] as int;
        String hi_who = it["hi_who"] as String;
        int hi_id = it["hi"] as int;

        if (bots.containsKey(bot_id) && bots[bot_id]!.length >= 2) {
          var compareValues = [];

          if (low_who == "output") {
            if (!outputs.containsKey(low_id))
              outputs[low_id] = [];
            int low_value = bots[bot_id]!.first;
            compareValues.add(low_value);
            outputs[low_id]!.add(low_value);
          }
          else if (low_who == "bot") {
            if (!bots.containsKey(low_id))
              bots[low_id] = [];
            int low_value = bots[bot_id]!.first;
            compareValues.add(low_value);
            bots[low_id]!.add(low_value);
            bots[low_id]!.sort();
          }
          else {
            assert(false);
          }

          if (hi_who == "output") {
            assert(bots.containsKey(bot_id));
            if (!outputs.containsKey(hi_id))
              outputs[hi_id] = [];
            int hi_value = bots[bot_id]!.last;
            compareValues.add(hi_value);
            outputs[hi_id]!.add(hi_value);
          }
          else if (hi_who == "bot") {
            assert(bots.containsKey(bot_id));
            if (!bots.containsKey(hi_id))
              bots[hi_id] = [];
            int hi_value = bots[bot_id]!.last;
            compareValues.add(hi_value);
            bots[hi_id]!.add(hi_value);
            bots[hi_id]!.sort();
          }
          else {
            assert(false);
          }

          if (compareValues.contains(chip1Compare) &&
              compareValues.contains(chip2Compare)) {
            resultBotId = bot_id;
          }
        }
        else {
          queue.addLast(it);
        }
      }
    }

    if (part2) {
      var v1 = outputs[0]![0];
      var v2 = outputs[1]![0];
      var v3 = outputs[2]![0];

      return v1 * v2 * v3;
    }

    return resultBotId;
  }

  @override
  Future<void> run() async {
    print("Day10");

    var data = readData("../adventofcode_input/2016/data/day10.txt");

    var res1 = await solve(data, 61, 17);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day10_result.txt", 0));

    var res2 = await solve(data, 61, 17, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day10_result.txt", 1));
  }
}