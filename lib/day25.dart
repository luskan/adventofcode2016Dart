import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';

enum InstructionType { cpy, inc, dec, jnz, tgl, out }

class Day25 extends Day with ProblemReader, SolutionCheck {

  static String readData(var filePath) {
    var data = File(filePath).readAsStringSync();
    return data;
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

  int _loopHeuristic1(List<Map<String, dynamic>> ops, int cp, HashMap<String, int> registers) {
    if (cp < ops.length - 5) {
      if (ops[cp]['type'] == InstructionType.cpy &&
          ops[cp + 1]['type'] == InstructionType.inc &&
          ops[cp + 2]['type'] == InstructionType.dec &&
          ops[cp + 3]['type'] == InstructionType.jnz &&
          ops[cp + 4]['type'] == InstructionType.dec &&
          ops[cp + 5]['type'] == InstructionType.jnz) {

        var regB = ops[cp]['arg1'];
        var regC = ops[cp]['arg2'];
        var regA = ops[cp + 1]['arg1'];
        var reg3 = ops[cp + 2]['arg1'];
        var reg4 = ops[cp + 4]['arg1'];
        var offset3 = ops[cp + 3]['arg2'];
        var offset5 = ops[cp + 5]['arg2'];

        // Check context if it matches the pattern
        if (regC == reg3 &&  // op[0]: cpy b [c] and  op[2]: dec [c], uses the same register name
            reg3 == ops[cp + 3]['arg1'] &&  // op[2]: dec [c] and op[3]: jnz [c] -2, uses the same register name
            reg4 == ops[cp + 5]['arg1'] &&  // op[4]: dec [d] and op[5]: jnz [d] -5, uses the same register name
            offset3 == -2 && offset5 == -5) {

          // Ensure all registers are valid, ie. they are variables a,b,c - and not some integer.
          if (registers.containsKey(regB) && registers.containsKey(regC) && registers.containsKey(reg4)) {
            registers[regA] = registers[regA]! + (registers[regB]! * registers[reg4]!);
            registers[regC] = 0;
            registers[reg4] = 0;
            return cp + 6;
          }
        }
      }
    }
    return cp;
  }

  Future<int> solve(dynamic data, {var part2 = false}) async {
    for (var a = 0; a < 10000; a++) {
      if (isCorrectSignal(data, a, part2: part2))
        return a;
    }
    return 0;
  }

  bool isCorrectSignal(List<Map<String, dynamic>> data, int value_a, {var part2 = false}) {

    var outCount = 0;

    int cp = 0;
    var registers = HashMap<String, int>.from({'a': value_a, 'b': 0, 'c': 0, 'd': 0});
    while (cp < data.length) {

      // heuristic optimization, replace multiplication with addition
      // actually needed only for part 2.
      cp = _loopHeuristic1(data, cp, registers);

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
        case InstructionType.tgl:
          var arg = instr['arg1'] is int ? instr['arg1'] : registers[instr['arg1']]!;
          var target = cp + arg;
          if (target >= 0 && target < data.length) {
            var targetInstr = data[target as int];
            switch (targetInstr['type']) {
              case InstructionType.inc:
                targetInstr['type'] = InstructionType.dec;
                break;
              case InstructionType.dec:
              case InstructionType.tgl:
                targetInstr['type'] = InstructionType.inc;
                break;
              case InstructionType.jnz:
                targetInstr['type'] = InstructionType.cpy;
                break;
              case InstructionType.cpy:
                targetInstr['type'] = InstructionType.jnz;
                break;
            }
          }
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
        case InstructionType.out:
          var arg1 = instr['arg1'] is int ? instr['arg1'] : registers[instr['arg1']]!;
          outCount++;
          // check if out is: signal of 0, 1, 0, 1...
          if (outCount % 2 == 0 && arg1 != 1) {
            return false;
          }
          if (outCount % 2 == 1 && arg1 != 0) {
            return false;
          }

          // 100 - is the number of signals to check, not sure if that
          // is a good heuristic, but it works for the input data.
          if (outCount == 100) {
            //print("Signal is correct for a=$value_a, outCount=$outCount");
            return true;
          }
          cp++;
          break;
      }
    }
    return true;
  }

  @override
  Future<void> run() async {
    print("Day25");

    var data = readData("../adventofcode_input/2016/data/day25.txt");

    var res1 = await solve(parseData(data));
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day25_results.txt", 0));
  }
}