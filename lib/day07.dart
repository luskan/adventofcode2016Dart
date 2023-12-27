import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';

class Sequence {
  bool isInSquareBrackets = false;
  String seq = "";

  Sequence(this.isInSquareBrackets, this.seq);
}

class Day07 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return  parseData(File(filePath).readAsLinesSync());
  }

  static dynamic parseData(List<String> lines) {
    final re = RegExp(r'[\[\]]');
    return lines.map((line) {
      var sequences = line.split(re);
      var seqArr = [];
      var isInBrackets = line[0] == '[';
      for (var s in sequences) {
        if (s.isEmpty) {
          isInBrackets = !isInBrackets;
          continue;
        }
        var seq = Sequence(isInBrackets, s);
        seqArr.add(seq);
        isInBrackets = !isInBrackets;
      }
      return seqArr;
    }).toList();
  }

  solve(List<List<dynamic>> data, {var part2 = false}) async {
    var count = 0;
    data.forEach((el) {
      if (part2) {
        if (supportsSSL(el))
          count++;
      }
      else {
        if (supportsTLS(el))
          count++;
      }
    });
    return count;
  }

  bool supportsTLS(List<dynamic> el) {
    var seqCount = 0;
    for (var seq in el) {
      var isABBA = false;
      for (var i = 0; i < seq.seq.length - 3; ++i) {
        if (seq.seq[i] != seq.seq[i + 1]
            && seq.seq[i] == seq.seq[i + 3]
            && seq.seq[i + 1] == seq.seq[i + 2]) {
          isABBA = true;
        }
      }
      if (isABBA) {
        if (seq.isInSquareBrackets) {
          seqCount = 0;
          break;
        }
        else {
          seqCount++;
        }
      }
    }
    return seqCount != 0;
  }

  bool supportsSSL(List<dynamic> el) {
    var seqCount = 0;
    var abas = [];
    var babas = [];

    for (var seq in el) {

      // ABA
      if(!seq.isInSquareBrackets) {
        for (var i = 0; i < seq.seq.length - 2; ++i) {
          if (seq.seq[i] != seq.seq[i + 1]
              && seq.seq[i] == seq.seq[i + 2]) {
            abas.add(seq.seq.substring(i, i+3));
          }
        }
      }
      // BAB
      if(seq.isInSquareBrackets) {
        for (var i = 0; i < seq.seq.length - 2; ++i) {
          if (seq.seq[i] != seq.seq[i + 1]
              && seq.seq[i] == seq.seq[i + 2]) {
            babas.add(seq.seq.substring(i, i + 3));
          }
        }
      }
    }

    //
    for (var aba in abas) {
      String babToFind = aba[1] + aba[0] + aba[1];
      var index = babas.indexOf(babToFind);
      if (index != -1) {
        seqCount++;
      }
    }
    return seqCount != 0;
  }

  @override
  Future<void> run() async {
    print("Day07");

    var data = readData("../adventofcode_input/2016/data/day07.txt");

    var res1 = await solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day07_result.txt", 0));

    var res2 = await solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day07_result.txt", 1));
  }
}