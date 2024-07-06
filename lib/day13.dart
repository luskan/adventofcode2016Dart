import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';
import 'package:collection/collection.dart';

import 'common.dart';

class Cell {
  int distFromStart = maxInt; // Also, indicates that node was visited (if non maxInt)
  bool isWall = false;
  Point prevNode = Point(0, 0);
  Cell(this.distFromStart, this.prevNode, this.isWall);
}
typedef CellMap = Map<Point, Cell>;

class Day13 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return int.parse(File(filePath).readAsStringSync());
  }

  /*
  Find x*x + 3*x + 2*x*y + y + y*y.
Add the office designer's favorite number (your puzzle input).
Find the binary representation of that sum; count the number of bits that are 1.
If the number of bits that are 1 is even, it's an open space.
If the number of bits that are 1 is odd, it's a wall.

  0123456789
0 .#.####.##
1 ..#..#...#
2 #....##...
3 ###.#.###.
4 .##..#..#.
5 ..##....#.
6 #...##.###

*/
  bool isWall(int x, int y, int favoriteNumber) {
    var num = x * x + 3 * x + 2 * x * y + y + y * y + favoriteNumber;
    var bits = num.toRadixString(2).split('').where((element) => element == '1').length;
    return bits % 2 == 1;
  }

  var cellMap = CellMap();

  Future<int> solve(int favoriteNumber, Point end, {var part2 = false}) async {
    var unvisited = PriorityQueue<Point>((a,b) {
      int d1 = cellMap[a]!.distFromStart;
      int d2 = cellMap[b]!.distFromStart;

      assert(d1 != maxInt);
      assert(d2 != maxInt);

      return d1 - d2;
    });

    cellMap[Point(1,1)] = Cell(0, Point(1,1), isWall(1, 1, favoriteNumber));
    assert(cellMap[Point(1,1)]!.isWall == false);
    unvisited.add(Point(1,1));

    void tryAddNextNode(int xOff, int yOff, Point prevNodePos) {
      int x = prevNodePos.x + xOff;
      if (x < 0)
        return;

      int y = prevNodePos.y + yOff;
      if (y < 0)
        return;

      assert(cellMap[prevNodePos] != null);
      var isWallCell = isWall(x, y, favoriteNumber);
      if (isWallCell)
        return;

      var newDistFromStart = cellMap[prevNodePos]!.distFromStart + 1;

      Cell cell = Cell(newDistFromStart, prevNodePos, isWallCell);
      if (!cellMap.containsKey(Point(x, y))) {
        cellMap[Point(x, y)] = cell;
        unvisited.add(Point(x, y));
      } else {
        if (cellMap[Point(x, y)]!.distFromStart > newDistFromStart) {
          cellMap[Point(x, y)] = cell;
        }
      }
    }

    while(!unvisited.isEmpty) {
      var nod = unvisited.removeFirst();
      tryAddNextNode(0, -1, nod);
      tryAddNextNode(-1, 0, nod);
      tryAddNextNode(1, 0, nod);
      tryAddNextNode(0, 1, nod);
    }

    //assert(cellMap[end]!.distFromStart != maxInt);
    int minDist = cellMap[end]?.distFromStart ?? -1;
   // print("minDist = $minDist");
    return minDist;
  }

  Future<int> solve2(int favoriteNumber) async {
    int count = 0;
    for (int x = -50; x <= 50; x++) {
      for (int y = -50; y <= 50; y++) {

        Point end = Point(1 + x, 1 + y);
        if (end.x < 0 || end.y < 0)
          continue;

        if (isWall(end.x, end.y, favoriteNumber)) {
          continue;
        } else {
          int dist = await solve(favoriteNumber, end);
          if (dist <= 50 && dist >= 0) {
            count++;
          }
        }
      }
    }

    return count;
  }

  @override
  Future<void> run() async {
    print("Day13");

    var data = readData("../adventofcode_input/2016/data/day13.txt");

    var res1 = await solve(data, Point(31,39));
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day13_results.txt", 0));

    var res2 = await solve2(data); //1030 too high,
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day13_results.txt", 1));
  }

}