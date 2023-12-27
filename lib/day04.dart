import 'dart:convert';
import 'dart:io';

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

class RoomItem {
  var enc_name;
  var id;
  var checksum;
  RoomItem(this.enc_name, this.id, this.checksum);
}

//@WorkingOnDayTag()
@DayTag()
class Day04 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static dynamic parseData(var data) {
    // etyyx-bzmcx-qdzbpthrhshnm-755[bksta]
    String regMatch = r'^([\w\d-]+?)-(\d+)\[([\w\d]+)\]$';
    RegExp rg = RegExp(regMatch);
    return LineSplitter()
        .convert(data)
        .map((e) => e.trim())
        .where((value) => value.isNotEmpty)
        .map((e) {
          var matches = rg.allMatches(e);
          var m = matches.elementAt(0);
          var g1 = m.group(1);
          var g2 = m.group(2);
          var g3 = m.group(3);
          return RoomItem(g1, g2, g3);
        })
        .toList();
  }

  int solve(var data, {var part2 = false, String roomNameToFind = ""}) {
    var result = 0;

    data.forEach((el) {
      var charMap = {};
      for (var ic = 0; ic < el.enc_name.length; ++ic) {
        var c = el.enc_name[ic];
        if (c != '-') {
          charMap.update(c, (old) => old + 1, ifAbsent: () => 1);
        }
      }
      var charArr = [];
      charMap.forEach((key, value) => charArr.add(key));
      charArr.sort((a, b) {
        var ca = charMap[a];
        var cb = charMap[b];
        if (ca == cb)
          return a.compareTo(b);
        return charMap[b] - charMap[a];
      });
      var computedChecksum = charArr.join();
      if (computedChecksum.substring(0, el.checksum.length) == el.checksum) {
        if (part2) {
          var charArr = el.enc_name.split("");
          var letterACU = "a".codeUnitAt(0);
          var shift = int.parse(el.id);
          for (var ic = 0; ic < charArr.length; ++ic) {
            var c = charArr[ic];
            if (c == '-') {
              c = ' ';
            }
            else {
              int cu = c.codeUnitAt(0);
              cu -= letterACU;
              cu += shift;
              cu %= 26;
              cu += letterACU;
              c = String.fromCharCode(cu);
            }
            charArr[ic] = c;
          }
          var resStr = charArr.join();
          //print(resStr);
          if (resStr == roomNameToFind)
            result = int.parse(el.id);
        }
        else {
          result += int.parse(el.id);
        }
      }
    });

    return result;
  }

  @override
  Future<void> run() async {
    print("Day04");

    var data = readData("../adventofcode_input/2016/data/day04.txt");

    var res1 = solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day04_result.txt", 0));

    var res2 = solve(data, part2: true, roomNameToFind: "northpole object storage");
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day04_result.txt", 1));
  }
}
