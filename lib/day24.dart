import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';
import 'package:collection/collection.dart';

import 'common.dart';

class ParsedData {
  final Map<Point, int> grid;
  final Map<int, Point> nodePositions;

  ParsedData(this.grid, this.nodePositions);
}

class GridEntry {
  int distFromStart;
  Point? prevNode;

  GridEntry(this.distFromStart, this.prevNode);

  void clear() {
    distFromStart = maxInt;
    prevNode = null;
  }
}

// Held–Karp implementation
int heldKarp(Map<int, Map<int, int>> distances, int start) {
  int n = distances.keys.length;

  // DP table: dp[mask][i] represents the minimum cost to visit nodes in mask ending at i
  var dp = List.generate(1 << n, (_) => List.filled(n, double.infinity));
  dp[1 << start][start] = 0;

  // Iterate over all masks
  for (int mask = 1; mask < (1 << n); mask++) {
    for (int i = 0; i < n; i++) {
      if ((mask & (1 << i)) != 0) { // If i is in the current mask
        for (int j = 0; j < n; j++) {
          if (i != j && (mask & (1 << j)) != 0) { // If j is in the mask
            dp[mask][i] = min(dp[mask][i], dp[mask ^ (1 << i)][j] + distances[j]![i]!);
          }
        }
      }
    }
  }

  // Find the minimum cost to visit all nodes ending at any node
  int allVisitedMask = (1 << n) - 1;
  double minCost = double.infinity;
  for (int i = 0; i < n; i++) {
    if (i != start) {
      minCost = min(minCost, dp[allVisitedMask][i]);
    }
  }

  return minCost.toInt();
}

// Parse the input and compute shortest distances between all numbered nodes
Map<int, Map<int, int>> computeDistanceMatrix(Map<int, Point> nodes, Map<Point, int> grid) {

  // BFS to compute distances between nodes
  Map<int, Map<int, int>> distances = {};
  for (int start in nodes.keys) {
    distances[start] = _bfs(grid, nodes[start]!, nodes);
  }

  return distances;
}

// Breadth-First Search to calculate distances from one node to all others
Map<int, int> _bfs(Map<Point, int> grid, Point start, Map<int, Point> nodes) {
  Map<Point, int> visited = {start: 0};
  List<Point> queue = [start];

  while (queue.isNotEmpty) {
    Point current = queue.removeAt(0);
    int currentDist = visited[current]!;

    for (var direction in [
      Point(0, 1),
      Point(1, 0),
      Point(0, -1),
      Point(-1, 0)
    ]) {
      Point next = Point(current.x + direction.x, current.y + direction.y);

      if (grid.containsKey(next) &&
          !visited.containsKey(next)) {
        visited[next] = currentDist + 1;
        queue.add(next);
      }
    }
  }

  // Extract distances to nodes
  Map<int, int> result = {};
  for (var entry in nodes.entries) {
    if (visited.containsKey(entry.value)) {
      result[entry.key] = visited[entry.value]!;
    }
  }
  return result;
}

int findMultiPointRoute(Map<int, Point> points, Map<Point, int> grid) {
  var distances = computeDistanceMatrix(points, grid);
  var minDist = heldKarp(distances, 0);

  return minDist;
}

class Day24 extends Day with ProblemReader, SolutionCheck {
  static String readData(var filePath) {
    var data = File(filePath).readAsStringSync();
    return data;
  }

  static ParsedData parseData(var data) {
    Map<Point, int> grid = {};
    Map<int, Point> nodePositions = {};

    List<String> lines = data.split('\n');
    for (int y = 0; y < lines.length; y++) {
      if (lines[y].trim().isEmpty) continue;
      for (int x = 0; x < lines[y].length; x++) {
        String value = lines[y][x];
        if (value == "#") continue;

        Point point = Point(x, y);
        grid[point] = value == "." ? -1 : int.parse(value);

        if (RegExp(r'^[0-9]$').hasMatch(value)) {
          var v = int.parse(value);
          nodePositions[v] = point;
        }
      }
    }
    return ParsedData(grid, nodePositions);
  }

  Future<int> solve(ParsedData data, {var part2 = false}) async {
    return findMultiPointRoute(data.nodePositions, data.grid);
  }

  @override
  Future<void> run() async {
    print("Day24");

    var data = readData("../adventofcode_input/2016/data/day24.txt");

    var res1 = await solve(parseData(data));
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day24_results.txt", 0));

    var res2 = await solve(parseData(data), part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day24_results.txt", 1));
  }
}
