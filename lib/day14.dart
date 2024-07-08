import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';
import 'package:collection/collection.dart';

import 'dart:async';
import 'dart:isolate';
import 'package:crypto/crypto.dart';
import 'dart:convert';


import 'common.dart';

String getHash(String salt, int index, bool part2) {
  var input = "$salt$index";
  if (part2) {
    for (var i = 0; i < 2016; i++) {
      input = md5.convert(utf8.encode(input)).toString();
    }
  }
  var hash = md5.convert(utf8.encode(input)).toString();
  return hash;
}

void hashWorker(SendPort sendPort) {
  ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    var data = message[0] as Map<String, dynamic>;
    var start = data['start'] as int;
    var end = data['end'] as int;
    var salt = data['salt'] as String;
    var part2 = data['part2'] as bool;
    var responsePort = message[1] as SendPort;

    Map<int, String> result = {};
    for (int index = start; index < end; index++) {
      result[index] = getHash(salt, index, part2);
    }
    responsePort.send(result);
  });
}

Future<Map<int, String>> computeHashes(String salt, int n, bool part2) async {
  int numberOfIsolates = Platform.numberOfProcessors+1;  // Adjust based on the number of CPU cores
  int batchSize = (n / numberOfIsolates).ceil();
  List<Future<Map<int, String>>> futures = [];

  for (int i = 0; i < numberOfIsolates; i++) {
    int start = i * batchSize;
    int end = (i + 1) * batchSize > n ? n : (i + 1) * batchSize;
    futures.add(spawnIsolate(salt, start, end, part2));
  }

  var results = await Future.wait(futures);
  Map<int, String> allResult = {};

  for (var element in results) {
    allResult.addAll(element);
  }
  return allResult;
}

Future<Map<int, String>> spawnIsolate(String salt, int start, int end, bool part2) async {
  ReceivePort receivePort = ReceivePort();
  Isolate isolate = await Isolate.spawn(hashWorker, receivePort.sendPort);
  SendPort sendPort = await receivePort.first as SendPort;

  ReceivePort responsePort = ReceivePort();
  sendPort.send([{
    'salt': salt,
    'start': start,
    'end': end,
    'part2': part2
  }, responsePort.sendPort]);

  var result = await responsePort.first as Map<int, String>;
  isolate.kill(priority: Isolate.immediate);
  return result;
}

class Day14 extends Day with ProblemReader, SolutionCheck {

  static dynamic readData(var filePath) {
    return File(filePath).readAsStringSync();
  }

  Map<int, String> hashCache = {};
  String getHashInternal(String salt, int index, part2) {
    if (hashCache.containsKey(index)) {
      return hashCache[index]!;
    }
    print("missing: $index");
    var hash = getHash(salt, index, part2);
    hashCache[index] = hash;
    return hash;
  }

  Future<int> solve(String salt, {var part2 = false}) async {
    var indexedHashCache = List.filled(1000, "");

    int findKey(int index) {
      var hash = indexedHashCache[index % 1000];
      indexedHashCache[index % 1000] = getHashInternal(salt, index + 1000, part2);

      for (int k = 0; k < hash.length - 2; k++) {
        if (hash[k] == hash[k + 1] && hash[k] == hash[k + 2]) {
          var c = hash[k];
          for (var i = index + 1; i < index + 1001; i++) {
            var hash2 = indexedHashCache[i % 1000];
            var c5 = "$c$c$c$c$c";
            if (hash2.contains(c5))
              return index;
          }
          return -1;
        }
      }

      return -1;
    }

    hashCache = await computeHashes(salt, 23423, part2);

    for (int i = 0; i < 1000; ++i) {
      indexedHashCache[i] = getHashInternal(salt, i, part2);
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