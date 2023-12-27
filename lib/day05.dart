import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:convert/convert.dart';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import "package:isolate/isolate.dart";

import 'dart:math' as math;

import 'common.dart';
import 'day.dart';
import 'solution_check.dart';

const String MSG_GET_MORE_DATA = "getmoredata";
const String MSG_COMPUTE = "compute";

String listToString(List<int> asciiList) {
  return asciiList.map((code) => String.fromCharCode(code)).join();
}

int countDigits(int n) {
  if (n == 0) return 1;
  int count = 0;
  while (n > 0) {
    n ~/= 10;
    count++;
  }
  return count;
}

compute(msg) async {
  var sendPort = msg[0] as SendPort;
  ReceivePort receivePort = ReceivePort();
  receivePort.listen((values) async {
    String msg = values[0] as String;

    if (msg == MSG_COMPUTE) {
      var data = values[1];
      var start = values[2];
      var end = values[3];
      var part2 = values[4];
      var result = values[5] as SendPort;

      var res = {};
      var list = <int>[];
      for (var i = 0; i < data.length; ++i) {
        list.add(data.codeUnitAt(i));
      }

      var zeroCodeUnit = '0'.codeUnitAt(0);

      for (var i = start; i < end; ++i) {
        // Extract digits from the number.
        var number = i;
        var k = data.length; // Start from the current length of data

        int numOfDigits = countDigits(number); // Get the number of digits

        if (number == 0) {
          if (list.length <= k) {
            list.add(zeroCodeUnit);
          } else {
            list[k] = zeroCodeUnit;
          }
        } else {
          while (number > 0) {
            int digit = number % 10 + zeroCodeUnit;
            number ~/= 10;
            numOfDigits--;

            int insertPos = k + numOfDigits;
            while (list.length <= insertPos) {
              list.add(0);
            }
            list[insertPos] = digit; // Insert digit at the calculated position
          }
        }

        var value = md5.convert(list);

        /*
        // No gain at all here.

        const int chunkSize = 1024;
        var output = AccumulatorSink<Digest>();
        var input = md5.startChunkedConversion(output);
        // Process the list in chunks
        for (int i = 0; i < list.length; i += chunkSize) {
          int end = i + chunkSize < list.length ? i + chunkSize : list.length;
          input.add(Uint8List.fromList(list.sublist(i, end)));
        }
        // Finalize the hashing process
        input.close();
        var value = output.events.single;
        */

        // Logic to check if we found a hash which can be used to get a card code
        // It must start with 5 zeros.
        if (value.bytes[0] == 0 && value.bytes[1] == 0 && value.bytes[2] < 16) {
          var str = value.toString();
          //rint("$data$i: $str");
          if (part2) {
            // In part2 we have more advances logic, we use 6 value as index where to put 7th value in
            // the card code.
            if (str[5].codeUnitAt(0) >= "0".codeUnitAt(0) &&
                str[5].codeUnitAt(0) <= "7".codeUnitAt(0)) {
              int index = str[5].codeUnitAt(0) - "0".codeUnitAt(0);
              if (!res.containsKey(index)) {
                // Because we use multiple isolates we return also the number (i) for which
                // this number was found. Only the earliest number is used which can be
                // found in the other isolate.
                res[index] = [i, str[6]];
              }
            }
          } else {
            res[i] = str[5];
          }
        }
      }

      // Send results
      result.send(res);
      // And request more data if available
      sendPort.send([MSG_GET_MORE_DATA, receivePort.sendPort]);
    }
  });

  // Request data, this message is the first one sent to the main message pump
  // Then above listener is getting its data.
  sendPort.send([MSG_GET_MORE_DATA, receivePort.sendPort]);
}

//@WorkingOnDayTag()
@DayTag()
class Day05 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return parseData(File(filePath).readAsStringSync());
  }

  static dynamic parseData(var data) {
    return data;
  }

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  solve(var data, {var part2 = false}) async {
    // Result code
    var result = "";

    // Partial results used by part2 solution
    var resultArr = List.filled(8, "?");
    var resultArrI = List.filled(8, maxInt);  // resultArrI[n] is the number for which resultArr[n] was found

    // Partial results used by part1 solution
    var part1IndToDigit = {};

    var foundDigits = 0;
    var th = 0;
    var processedRange = 0;

    SingleResponseChannel donePort = SingleResponseChannel();
    var receivePort = ReceivePort();

    final numberOfIsolates = Platform.numberOfProcessors;
    var maxRangeToCheck = part2 ? 34000000 : 20000000; // This is the (almost) lowest number for which I got the correct result.
                                    // with additional trackin of processed and found number it would be possible
                                    // to eliminate this value and use maxInt instead.
    int perIsolateJobCount = 1;
    int perIsolateJobSize = (maxRangeToCheck ~/ numberOfIsolates) ~/ perIsolateJobCount;
    maxRangeToCheck = perIsolateJobSize * numberOfIsolates * perIsolateJobCount;

    // Start main message pump
    receivePort.listen((value) async {
      String msg = value[0] as String;
      if (msg == MSG_GET_MORE_DATA) {
        var rangeStart = th * perIsolateJobSize;
        var rangeEnd = (th + 1) * perIsolateJobSize;

        if (rangeEnd <= maxRangeToCheck)
        {
          SendPort sp = value[1];
          SingleResponseChannel src = SingleResponseChannel();
          sp.send([MSG_COMPUTE, data, rangeStart, rangeEnd, part2, src.port]);
          th++;

          var res = await src.result;

          processedRange += perIsolateJobSize;

          if (part2) {
            for (var i = 0; i < 8; ++i) {
              if (res.containsKey(i) && resultArrI[i] > res[i][0]) {
                resultArr[i] = res[i][1];
                resultArrI[i] = res[i][0];
                foundDigits++;
              }
            }
          } else {
            part1IndToDigit.addAll(res);
            foundDigits = part1IndToDigit.length;
          }

          if (foundDigits >= 8) {
            if (!part2) {
              var indArr = [];
              part1IndToDigit.forEach((key, value) {
                indArr.add(key);
              });
              indArr.sort();
              result = "";
              for (var ind in indArr) {
                result += part1IndToDigit[ind];
              }
            }
            if (processedRange == maxRangeToCheck) {
              donePort.port.send(result);
            }
          }
        }
      }
    });

    // Using all the same number of isolates as cores is 3 times faster than using single isolate.
    // On 8 core i7 cpu, for one isolate it takes 0:01:04 versus 0:00:23 for 8 isolates.
    // TODO: Check why using Platform.numberOfProcessors+1 makes algorithm never stop
    print("numberOfIsolates = ${numberOfIsolates}");
    var cpus = numberOfIsolates;
    for (var c = 0; c < cpus; ++c) {
      Isolate.spawn(compute, [receivePort.sendPort]);
    }
    result = await donePort.result;
    receivePort.close();

    if (part2) result = resultArr.join();
    return result;
  }

  @override
  Future<void> run() async {
    print("Day05");

    var data = readData("../adventofcode_input/2016/data/day05.txt");

    var res1 = (await solve(data)).substring(0, 8);
    print('Part1: $res1');
    verifyResult(
        res1.substring(0, 8),
        getStringFromFile(
            "../adventofcode_input/2016/data/day05_result.txt", 0));

    var res2 = await solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(
        res2,
        getStringFromFile(
            "../adventofcode_input/2016/data/day05_result.txt", 1));
  }
}

DigestSink() {}
