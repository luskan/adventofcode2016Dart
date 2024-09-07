import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'common.dart';

class Day21 extends Day with ProblemReader, SolutionCheck {

  static String readData(var filePath) {
    var data = File(filePath).readAsStringSync();
    return data;
  }

  static dynamic parseData(var data) {

    return data;
  }

  //var part1Results = <String>[];

  Future<String> solve(dynamic data, String startWord, {var part2 = false}) async {
    var instructions = LineSplitter().convert(data);

    /*
    swap position 4 with position 0
    swap letter d with letter b
    reverse positions 0 through 4
    rotate left 1 step
    move position 1 to position 4
    rotate based on position of letter b
    */
    var word = startWord.split('');
    int instructionIndex = part2 ? instructions.length-1 : 0;
    while (true)
    {
      if (instructionIndex < 0 || instructionIndex >= instructions.length)
        break;
      var instruction = instructions[instructionIndex];
      if (part2)
        instructionIndex--;
      else
        instructionIndex++;

      /*
      // Code for finding errors in part2
      if (!part2) {
        //part1Results.add(line);
      }
      else
        {
          var line = "Instruction: $instruction, word: ${word.join('')}";
          var part1Line = part1Results[instructionIndex+1];
          if (part1Line != line)
            {
              var part1LinePrev = part1Results[instructionIndex+1 + 1];
              break;
            }
        }
      */

      //
      var parts = instruction.split(' ');
      if (parts[0] == 'swap') {
        if (parts[1] == 'position') {
          var x = int.parse(parts[2]);
          var y = int.parse(parts[5]);
          if (part2) {
            var tmp = y;
            y = x;
            x = tmp;
          }
          var tmp = word[x];
          word[x] = word[y];
          word[y] = tmp;
        } else { // letter
          var x = parts[2];
          var y = parts[5];
          var xIndex = word.indexOf(x);
          var yIndex = word.indexOf(y);
          word[xIndex] = y;
          word[yIndex] = x;
        }
      } else if (parts[0] == 'rotate') {
        if (!part2 && parts[1] == 'left' || part2 && parts[1] == 'right') {
          var steps = int.parse(parts[2]);
          for (var i = 0; i < steps; i++) {
            var first = word.removeAt(0);
            word.add(first);
          }
        } else if (!part2 && parts[1] == 'right' || part2 && parts[1] == 'left') {
          var steps = int.parse(parts[2]);
          for (var i = 0; i < steps; i++) {
            var last = word.removeLast();
            word.insert(0, last);
          }
        } else {
          if (!part2) {
            var x = word.indexOf(parts[6]);
            var steps = x + 1;
            if (x >= 4) {
              steps++;
            }
            for (var i = 0; i < steps; i++) {
              var last = word.removeLast();
              word.insert(0, last);
            }
          }
          else {
            var x = word.indexOf(parts[6]);
            /*
            pos   shift  newpos
              0     1      1
              1     2      3
              2     3      5
              3     4      7
              4     6      2
              5     7      4
              6     8      6
              7     9      0
           */
            var steps = (x ~/ 2) + (x % 2 == 1 || x == 0 ? 1 : 5);
            for (var i = 0; i < steps; i++) {
              var first = word.removeAt(0);
              word.add(first);
            }
          }
        }
      } else if (parts[0] == 'reverse') {
        if (!part2) {
          var x = int.parse(parts[2]);
          var y = int.parse(parts[4]);
          var reversed = word
              .sublist(x, y + 1)
              .reversed
              .toList();
          word = word.sublist(0, x) + reversed + word.sublist(y + 1);
        }
        else {
          var x = int.parse(parts[2]);
          var y = int.parse(parts[4]);
          var reversed = word
              .sublist(x, y + 1)
              .reversed
              .toList();
          word = word.sublist(0, x) + reversed + word.sublist(y + 1);
        }
      } else if (parts[0] == 'move') {
        if (!part2) {
          var x = int.parse(parts[2]);
          var y = int.parse(parts[5]);
          var char = word.removeAt(x);
          word.insert(y, char);
        }
        else {
          var x = int.parse(parts[5]);
          var y = int.parse(parts[2]);
          var char = word.removeAt(x);
          word.insert(y, char);
        }
      }

      /*
      // Code for finding errors in part2
      if (!part2) {
        var line = "Instruction: $instruction, word: ${word.join('')}";
        part1Results.add(line);
      }
      */
    }

    return word.join('');
  }

  @override
  Future<void> run() async {
    print("Day21");

    var data = readData("../adventofcode_input/2016/data/day21.txt");

    var res1 = await solve(data, "abcdefgh");
    print('Part1: $res1');
    verifyResult(res1, getStringFromFile("../adventofcode_input/2016/data/day21_results.txt", 0));

    // Verification code
    //var res2x = await solve(data, "hcdefbag", part2: true);
    //verifyResult(res2x, "abcdefgh");

    var res2 = await solve(data, "fbgdceah", part2: true); // wrong: hcdegabf
    print('Part2: $res2');
    verifyResult(res2, getStringFromFile("../adventofcode_input/2016/data/day21_results.txt", 1));
  }
}