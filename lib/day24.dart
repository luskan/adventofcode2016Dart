import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

import 'package:image/image.dart' as img;

import 'common.dart';

class ParsedData {
  final Map<Point, int> grid;
  final Map<int, Point> nodePositions;
  final int width;
  final int height;

  ParsedData(this.grid, this.nodePositions, this.width, this.height);
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

/***
 * Held-Karp algorithm to solve the Travelling Salesman Problem (TSP).
 * distances: A nested map where distances[i][j] is the cost/distance between node i and node j.
 * startPoint: The starting point for the journey - [0, pointsCounts-1].
 * returnToStart: Whether the TSP path must return to the start node.
 * pointsPath: returns indexes of the points in the path. This is the order of the points to visit.
 * pointsOrdered: returns the points in the path. This is the order of the points to visit.
 */
int heldKarp(
    Map<int, Map<int, Map<String, dynamic>>> distances,
    int pointsCounts,
    int startPoint,
    bool returnToStart,
    bool reconstructPath,
    List<Point> pointsPath,
    List<Point> pointsOrdered)
{
  int n = pointsCounts;
  var dp = List.generate(1 << n, (_) => List.filled(n, double.infinity));
  Map<int, Map<int, int>> parent = {};

  dp[1 << startPoint][startPoint] = 0;

  for (int mask = 1; mask < (1 << n); mask++) {
    for (int i = 0; i < n; i++) {
      if ((mask & (1 << i)) != 0) {
        for (int j = 0; j < n; j++) {
          if (i != j && (mask & (1 << j)) != 0) {
            double newCost =
                dp[mask ^ (1 << i)][j] + distances[j]![i]!['distance'];
            if (newCost < dp[mask][i]) {
              dp[mask][i] = newCost;
              parent[mask] ??= {};
              parent[mask]![i] = j;
            }
          }
        }
      }
    }
  }

  int allVisitedMask = (1 << n) - 1;
  double minCost = double.infinity;
  int endPoint = -1;

  for (int i = 0; i < n; i++) {
    if (i != startPoint) {
      double cost = dp[allVisitedMask][i];
      if (returnToStart) {
        cost += distances[i]![startPoint]!['distance'];
      }
      if (cost < minCost) {
        minCost = cost;
        endPoint = i;
      }
    }
  }

  // Reconstruct the path
  if (reconstructPath) {
    //pointsPath.add(distances[startPoint]![endPoint]!['path'][0]); // Add the start point
    List<int> order = [];
    int mask = allVisitedMask;
    int currentNode = endPoint;

    while (currentNode != startPoint) {
      order.add(currentNode);
      int prevNode = parent[mask]![currentNode]!;
      mask ^= (1 << currentNode);
      currentNode = prevNode;
    }
    order = order.reversed.toList();

    // Reconstruct the entire path using stored paths between nodes
    for (int i = 0; i < order.length; i++) {
      int from = i == 0 ? startPoint : order[i - 1];
      int to = order[i];
      pointsOrdered.add(distances[from]![to]!['path'][0]); // Add the start point
      if (i + 1 == order.length)
        pointsOrdered.add((distances[from]![to]!['path'] as List).last);
      pointsPath.addAll(distances[from]![to]!['path'].skip(1)); // Skip the duplicate start point
    }

    if (returnToStart) {
      pointsPath.addAll(distances[order.last]![startPoint]!['path'].skip(1));
    }
  }

  return minCost.toInt();
}

// Parse the input and compute shortest distances between all numbered nodes
Map<int, Map<int, Map<String, dynamic>>> computeDistanceMatrix(
    Map<int, Point> nodes, Map<Point, int> grid) {
  Map<int, Map<int, Map<String, dynamic>>> distances = {};

  for (int start in nodes.keys) {
    distances[start] = _bfs(grid, nodes[start]!, nodes);
  }

  return distances;
}

// Breadth-First Search to calculate distances from one node to all others,
// it also stores the path to the nodes.
Map<int, Map<String, dynamic>> _bfs(
    Map<Point, int> grid,
    Point start,
    Map<int, Point> nodes) {
  Map<Point, int> visited = {start: 0};
  Map<Point, Point?> previousNode = {start: null};
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

      if (grid.containsKey(next) && !visited.containsKey(next)) {
        visited[next] = currentDist + 1;
        previousNode[next] = current;
        queue.add(next);
      }
    }
  }

  // Extract distances and reconstruct paths
  Map<int, Map<String, dynamic>> result = {};
  for (var entry in nodes.entries) {
    if (visited.containsKey(entry.value)) {
      // Reconstruct path
      List<Point> path = [];
      Point? current = entry.value;
      while (current != null) {
        path.add(current);
        current = previousNode[current];
      }
      result[entry.key] = {
        'distance': visited[entry.value]!,
        'path': path.reversed.toList(),
      };
    }
  }
  return result;
}

(int, Map<int, Map<int, Map<String, dynamic>>>) findMultiPointRoute(Map<int, Point> points,
    Map<Point, int> grid,
    List<Point> pathPoints,
    List<Point> pointsOrdered,
    bool returnToStart)
{
  var distances = computeDistanceMatrix(points, grid);

  // Brute force and Held-Karp algorithm complexities:
  // Brute force is n!
  // Held-Karp is 2^n * n^2
  //
  //              Time Complexity               Space Complexity
  //     |  Held-Karp   |  Brute force     |  Held-Karp |  Brute force
  // n   |  2^n * n^2   |   n!             |  2^n * n   |  n^2
  // ----------------------------------------------------------
  // 1   |      2       |    1             |      2     |   1
  // 2   |     16       |    2             |      8     |   4
  // 3   |     72       |    6             |     24     |   9
  // 4   |    256       |   24             |     64     |  16
  // 5   |    800       |  120             |    160     |  25
  // 6   |   2304       |  720             |    384     |  36
  // 7   |   6272       |  5040  <-- *     |    896     |  49
  // 8   |  16384       |  40320           |   2048     |  64
  // 9   |  41472       |  362880          |   4608     |  81
  // 10   | 102400       |  3628800        |  10240     | 100
  // 11   | 245760       |  39916800       |  22528     | 121
  // 12   | 589824       |  479001600      |  49152     | 144
  // 13   | 1376256      |  6227020800     | 106496     | 169
  // 14   | 3170304      |  87178291200    | 229376     | 196
  // 15   | 7200000      | 1307674368000   | 491520     | 225
  // * Brute force is acceptable for up to 7 nodes

  // Brute force is acceptable for less than 7 nodes
  // 0:00:00.152100
  //var minDist = bruteForce(distances, points.length, 0, returnToStart);

  // Held-Karp algorithm is slightly faster than brute force
  // 0:00:00.138446
  var minDist = heldKarp(distances, points.length, 0, returnToStart, true, pathPoints, pointsOrdered);
  return (minDist, distances);
}

void printMap(Map<Point, int> grid,
    Map<int, Map<int, Map<String, dynamic>>> distances,
    Map<int, Point> points,
    int width, int height,
    List<Point> pathPoints,
    List<Point> pointsOrdered) {

  stdout.writeln('Points ordered:');
  for (int i = 0; i < pointsOrdered.length - 1; i++) {
    var from = points.keys.firstWhere((k) => points[k] == pointsOrdered[i]);
    var to = points.keys.firstWhere((k) => points[k] == pointsOrdered[i + 1]);
    var steps = (distances[from]![to]!['distance'] as int);
    stdout.writeln('$from to $to ($steps steps)');
  }
  // Total steps
  stdout.writeln('Total steps: ${pathPoints.length}');

  stdout.writeln();
  for (int n = 0; n < pathPoints.length; ++n) {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        Point point = Point(x, y);
        if (grid.containsKey(point)) {
          int index = pathPoints.indexOf(point);
          if (index != -1 && index <= n) {
            stdout.write(grid[point] == -1 ? '*' : grid[point]);
          } else {
            stdout.write(grid[point] == -1 ? '.' : grid[point]);
          }
        } else {
          stdout.write('#');
        }
      }
      stdout.writeln();
    }
    stdout.writeln();
  }
}

bruteForce(Map<int, Map<int, int>> distances, int length, int i, bool returnToStart) {
  var minDist = maxInt;
  var path = List<int>.generate(length, (index) => index);
  var start = path.removeAt(i);
  var perms = permutations(path);
  for (var perm in perms) {
    var dist = 0;
    var prev = start;
    for (var node in perm) {
      dist += distances[prev]![node]!;
      prev = node;
    }
    if (returnToStart) {
      dist += distances[prev]![start]!;
    }
    minDist = min(minDist, dist);
  }
  return minDist;
}

List<List<int>> permutations(List<int> path) {
  if (path.length == 1) {
    return [path];
  }
  var perms = <List<int>>[];
  for (var i = 0; i < path.length; i++) {
    var subPath = List<int>.from(path);
    var node = subPath.removeAt(i);
    var subPerms = permutations(subPath);
    for (var perm in subPerms) {
      perm.add(node);
      perms.add(perm);
    }
  }
  return perms;
}

class Day24 extends Day with ProblemReader, SolutionCheck {
  static String readData(var filePath) {
    var data = File(filePath).readAsStringSync();
    return data;
  }

  static ParsedData parseData(var data) {
    Map<Point, int> grid = {};
    Map<int, Point> nodePositions = {};
    int height = 0;
    List<String> lines = data.split('\n');
    for (int y = 0; y < lines.length; y++) {
      if (lines[y].trim().isEmpty) continue;
      height++;
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
    return ParsedData(grid, nodePositions, lines[0].length, height);
  }

  Future<int> solve(ParsedData data, {var part2 = false}) async {
    List<Point> pathPoints = [];
    List<Point> pointsOrdered = [];
    var (minDist, distances) = findMultiPointRoute(data.nodePositions, data.grid, pathPoints, pointsOrdered, part2);
    printMap(data.grid, distances, data.nodePositions, data.width, data.height, pathPoints, pointsOrdered);

    return minDist;
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
