import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';
import 'package:collection/collection.dart';

import 'common.dart';

enum InstructionType { cpy, inc, dec, jnz }

class Day12 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return  parseData(File(filePath).readAsStringSync());
  }

  static dynamic parseData(String data) {
    return LineSplitter
        .split(data)
        .map((e) {
          var parts = e.split(' ');
          return {
            'type': InstructionType.values.byName(parts[0]),
            'arg1': (int.tryParse(parts[1]) == null ? parts[1] : int.tryParse(parts[1])),
            'arg2': parts.length > 2 ? (int.tryParse(parts[2]) == null ? parts[2] : int.tryParse(parts[2])) : null
          };
        }).toList();
  }

  Future<int> solve(dynamic data, {var part2 = false}) async {
    int cp = 0;
    var registers = HashMap<String, int>.from({'a': 0, 'b': 0, 'c': part2 ? 1 : 0, 'd': 0});
    while (cp < data.length) {
      var instr = data[cp];
      switch (instr['type']) {
        case InstructionType.cpy:
          if (instr['arg1'] is int) {
            registers[instr['arg2']] = instr['arg1'];
          } else {
            registers[instr['arg2']] = registers[instr['arg1']]!;
          }
          cp++;
          break;
        case InstructionType.inc:
          registers[instr['arg1']] = registers[instr['arg1']]! + 1;
          cp++;
          break;
        case InstructionType.dec:
          registers[instr['arg1']] = registers[instr['arg1']]! - 1;
          cp++;
          break;
        case InstructionType.jnz:
          var arg1 = instr['arg1'] is int ? instr['arg1'] : registers[instr['arg1']]!;
          if (arg1 != 0) {
            int jump = 0;
            if (instr['arg2'] is int)
              jump = instr['arg2'] as int;
            else
              jump = registers[instr['arg2']]!;
            cp += jump;
          }
          else
            cp++;
          break;
      }
    }
    return registers['a']!;
  }

  @override
  Future<void> run() async {
    print("Day12");

    var data = readData("../adventofcode_input/2016/data/day12.txt");

    var res1 = await solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day12_results.txt", 0));

    var res2 = await solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day12_results.txt", 1));
  }

}