import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';

class Day16 extends Day with ProblemReader, SolutionCheck {

  static String readData(var filePath) {
    var data = File(filePath).readAsStringSync();
    return data;
  }

  static dynamic parseData(var data) {
    return data;
  }

  String makeDragonCurveStep(String a) {
    var b = a.split('').reversed.map((e) => e == '0' ? '1' : '0').join();
    return '$a' + '0' + '$b';
  }

  Future<String> solve(dynamic data, int diskSize, {var part2 = false}) async {

    while (data.length < diskSize) {
      data = makeDragonCurveStep(data);
    }
    data = data.substring(0, diskSize);

    var checksum = StringBuffer();
    do {
      checksum.clear();
      for (var i = 0; i < data.length; i += 2) {
        if (data[i] == data[i + 1]) {
          checksum.write('1');
        } else {
          checksum.write('0');
        }
      }
      data = checksum.toString();
    } while (checksum.length % 2 == 0);

    return checksum.toString();
  }

  @override
  Future<void> run() async {
    print("Day16");

    var data = readData("../adventofcode_input/2016/data/day16.txt");

    var res1 = await solve(data, 272);
    print('Part1: $res1');
    verifyResult(res1, getStringFromFile("../adventofcode_input/2016/data/day16_results.txt", 0));

    var res2 = await solve(data, 35651584, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getStringFromFile("../adventofcode_input/2016/data/day16_results.txt", 1));
  }
}