import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';
import 'package:collection/collection.dart';

import 'common.dart';

class DFEntry {
  int x;
  int y;
  int size;
  int used;
  int avail;
  int use;

  // For A* calculation
  int distFromStart = maxInt;
  Point prevNode = Point(0, 0);
  void reset() {
    distFromStart = maxInt;
    prevNode = Point(0, 0);
  }

  DFEntry(this.x, this.y, this.size, this.used, this.avail, this.use);

  Point get pt => Point(x, y);

  bool isLarge() => size > 100; // Should be calculated from the input

  // Copy constructor
  DFEntry.copy(DFEntry other)
      : x = other.x,
        y = other.y,
        size = other.size,
        used = other.used,
        avail = other.avail,
        use = other.use;
}

/*
  The problem can be simplified to the problem of finding paths in a grin MxN with
  some elements beeing obstacles (the nodes with very large sizes). So it looks as following:

  0 - this is where we want to move G
  _ - empty node
  . - region where G cannot enter

  so, we can move G and . only into _, so the solution is to:
  1. Find a path from G to 0, one which will not enter any walls
  2. Move _ onto the next node on the path from G to 0
  3. Move G onto the _, this will leave _ on the previous node
  4. Go to 2, until G is on 0. Assume G is like a wall - so the _ cannot move on G.
  (or count the steps by hand :-) )

  0.....................................G
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  .......................................
  ......#################################
  .......................................
  .......................................
  .......................................
  ............._.........................
  .......................................

 */

class Day22 extends Day with ProblemReader, SolutionCheck {

  static String readData(var filePath) {
    var data = File(filePath).readAsStringSync();
    return data;
  }

  static dynamic parseData(var data) {
    var entriesMap = <Point, DFEntry>{};
    var lines = LineSplitter().convert(data);
    // Filesystem              Size  Used  Avail  Use%
    // /dev/grid/node-x0-y0     93T   67T    26T   72%
    final rg = RegExp(r"/dev/grid/node-x(?<xc>\d+)-y(?<yc>\d+)\s+(?<Size>\d+)T\s+(?<Used>\d+)T\s+(?<Avail>\d+)T\s+(?<Use>\d+)%");
    for (var line in lines) {
      if (line.contains("Filesystem") || line.contains("root@ebhq-gridcenter"))
        continue;
      var m = rg.firstMatch(line);
      assert(m != null);

      var entry = DFEntry(
          int.parse(m!.namedGroup("xc")!),
          int.parse(m.namedGroup("yc")!),
          int.parse(m.namedGroup("Size")!),
          int.parse(m.namedGroup("Used")!),
          int.parse(m.namedGroup("Avail")!),
          int.parse(m.namedGroup("Use")!));

      entriesMap[Point(entry.x, entry.y)] = entry;
    }

    return entriesMap;
  }

  DFEntry _findEmptyUsageEntry(Map<Point, DFEntry> entries) {
    return entries.values.reduce((value, element) {
      var node = entries[element.pt]!;
      if (node.used == 0)
        return node;
      return value;
    });
  }

  /// Finds the shortest path using Dijkstra's algorithm.
  ///
  /// This function calculates the shortest path from the `start` point to the `target` point
  /// in a grid represented by `entries`. The `extraWalls` parameter specifies additional
  /// points that should be considered as obstacles.
  ///
  /// \param entries A map of points to `DFEntry` objects representing the grid.
  /// \param start The starting point.
  /// \param target The target point.
  /// \param extraWalls A list of points that should be treated as obstacles.
  /// \returns A list of points representing the shortest path from `start` to `target`.
  List<Point> _findPathUsingDijkstra(Map<Point, DFEntry> entries,
      Point start, Point target, List<Point> extraWalls)
  {
    var dirs = [Point(0, -1), Point(1, 0), Point(0, 1), Point(-1, 0)];
    var visited = <Point>{};

    var unvisited = PriorityQueue<Point>((a,b) {
      var d1 = entries[a]!.distFromStart;
      var d2 = entries[b]!.distFromStart;
      return d1 - d2;
    });

    for (var entry in entries.values) {
      entry.reset();
    }

    unvisited.add(start);
    entries[start]!.distFromStart = 0;

    while (!unvisited.isEmpty) {
      var pt = unvisited.removeFirst();

      visited.add(pt);

      for (var dir in dirs) {
        var newPt = Point(pt.x + dir.x, pt.y + dir.y);
        if (!entries.containsKey(newPt))
          continue;
        if (extraWalls.contains(newPt))
          continue;
        var newEntry = entries[newPt]!;
        if (newEntry.isLarge())
          continue;
        if (visited.contains(newPt))
          continue;

        var newCost = newEntry.distFromStart + 1;
        if (newCost < newEntry.distFromStart) {
          newEntry.distFromStart = newCost;
          newEntry.prevNode = pt;
        }
        unvisited.add(newPt);
      }
    }

    // Create a list of points from target to empty space
    var path = <Point>[];
    var pt = target;
    while (pt != start) {
      path.add(pt);
      pt = entries[pt]!.prevNode;
    }
    return path.reversed.toList();
  }

  void printMap(Map<Point, DFEntry> entries, List<Point> path, Point emptyPtOverride, Point dataPtOverride) {
    var maxX = entries.keys.reduce((value, element) => element.x > value.x ? element : value).x;
    var maxY = entries.keys.reduce((value, element) => element.y > value.y ? element : value).y;

    var emptyUsageNode = emptyPtOverride == null ? _findEmptyUsageEntry(entries).pt : emptyPtOverride;

    for (var y = 0; y <= maxY; ++y) {
      for (var x = 0; x <= maxX; ++x) {
        var entry = entries[Point(x, y)]!;
        if (entry.x == 0 && entry.y == 0) {
          stdout.write("0");
        }
        else if (dataPtOverride != null && entry.x == dataPtOverride.x && entry.y == dataPtOverride.y) {
          stdout.write("G");
        }
        else
        if (emptyUsageNode == entry.pt) {
          stdout.write("_");
        }
        else if (entry.isLarge()) {
          stdout.write("#");
        }
        else {
          if (path.contains(entry.pt))
            stdout.write("*");
          else
            stdout.write(".");
        }
      }
      stdout.write("\n");
    }
  }

  Future<int> solve(dynamic data, {var part2 = false}) async {
    var entries = data as Map<Point, DFEntry>;

    if (!part2) {
      var viablePairs = 0;
      for (var e1 in entries.entries) {
        if (e1.value.used == 0) {
          continue;
        }
        for (var e2 in entries.entries) {
          if (e1 == e2)
            continue;
          if (e1.value.used <= e2.value.avail) {
            viablePairs++;
          }
        }
      }
      return viablePairs;
    }
    else {
      var numberOfSteps = 0;

      var topRight = entries.keys.reduce((value, element) {
        if (element.x > value.x)
          return element;
        else if (element.x == value.x && element.y < value.y)
          return element;
        else
          return value;
      });


      var dataPath = _findPathUsingDijkstra(entries, topRight, Point(0,0), []);

      // Walk the data path
      var emptyUsageNode = _findEmptyUsageEntry(entries);
      var emptyPt = emptyUsageNode.pt;
      var prevDataPt = Point(topRight.x, topRight.y);
      for (var dataPt in dataPath) {
        var path = _findPathUsingDijkstra(entries, emptyPt, dataPt, [prevDataPt]);

        print("\n");
        printMap(entries, [], emptyPt, prevDataPt);
        print("\n");
        for (var i = 0; i < path.length; ++i) {
          printMap(entries, [], path[i], prevDataPt);
          print("\n");
        }

        numberOfSteps += path.length + 1;
        emptyPt = prevDataPt;
        prevDataPt = dataPt;
      }

      return numberOfSteps;
    }
  }

  @override
  Future<void> run() async {
    print("Day22");

    var data = readData("../adventofcode_input/2016/data/day22.txt");

    var res1 = await solve(parseData(data));
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day22_results.txt", 0));

    var res2 = await solve(parseData(data), part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day22_results.txt", 1));
  }
}