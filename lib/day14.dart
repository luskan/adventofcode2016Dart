import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';
import 'package:collection/collection.dart';

import 'common.dart';

class Day14 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return File(filePath).readAsStringSync();
  }

  Future<int> solve(String salt, {var part2 = false}) async {
    var hashCache = List.filled(1000, "");

    String getHash(int index) {
      var input = "$salt$index";
      if (part2) {
        for (var i = 0; i < 2016; i++) {
          input = md5.convert(utf8.encode(input)).toString();
        }
      }
      var hash = md5.convert(utf8.encode(input)).toString();
      return hash;
    }

    //var rg = RegExp(r'(.)\1\1');

    int findKey(int index) {
      var hash = hashCache[index % 1000];
      hashCache[index % 1000] = getHash(index + 1000);

      for (int k = 0; k < hash.length - 2; k++) {
        if (hash[k] == hash[k + 1] && hash[k] == hash[k + 2]) {
          var c = hash[k];
          var quintuples = "$c$c$c$c$c";
          for (var i = index + 1; i < index + 1001; i++) {
            var hash2 = hashCache[i % 1000];
            if (hash2.contains(quintuples)) {
              return index;
            }
          }
          return -1;
        }
      }

      return -1;
    }

    for (int i = 0; i < 1000; ++i) {
      hashCache[i] = getHash(i);
    }

    var index = 0;
    var keys = <int>[];
    while (keys.length < 64) {
      var key = findKey(index);
      if (key != -1) {
        keys.add(key);
      }
      index++;
    }
    return keys.last;
  }

  @override
  Future<void> run() async {
    print("Day14");

    var data = readData("../adventofcode_input/2016/data/day14.txt");

    var res1 = await solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day14_results.txt", 0));

    var res2 = await solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day14_results.txt", 1));
  }

}