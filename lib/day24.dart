import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';

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

/***
 * Held-Karp algorithm to solve the Travelling Salesman Problem (TSP).
 * distances: A nested map where distances[i][j] is the cost/distance between node i and node j.
 * startPoint: The starting point for the journey - [0, pointsCounts-1].
 * returnToStart: Whether the TSP path must return to the start node.
 * pointsPath: returns indexes of the points in the path. This is the order of the points to visit.
 */
int heldKarp(Map<int, Map<int, int>> distances, int pointsCounts, int startPoint,
    bool returnToStart, List<int> pointsPath)
{

  // Step 1:total number of nodes (places).
  int n = pointsCounts;

  // Example:
  // If n = 4, places are numbered as 0, 1, 2, 3.

  // Step 2: Initialize the DP table (Held-Karp is a dynamic programming algorithm
  // which uses tabulation).
  // dp[mask][i] holds the minimum cost to visit the subset of nodes
  // represented by mask, ending at node i.
  //
  // dp table looks like this:
  // mask (subset of visited places) -> [cost for ending at place 0, place 1, ..., place n-1]
  // mask = 0011 -> [inf, 5, inf, inf] // Subset {0, 1}, ending at place 1, costs 5.
  //
  // 1 << n means 2^n, which represents all subsets of the n nodes.
  var dp = List.generate(1 << n, (_) => List.filled(n, double.infinity));

  // Step 3: Base case: Start at the start place with no travel cost.
  dp[1 << startPoint][startPoint] = 0;

  // 1 << start is a bitmask representing the subset {start}.
  // Example:
  // If start = 0 and n = 4, bitmask = 0001.

  // Step 4: Fill the DP table for all subsets and all ending nodes.
  for (int mask = 1; mask < (1 << n); mask++) {

    // Loop through all subsets of places represented by `mask`.
    //
    // mask example (n = 4):
    // 0001 -> Subset {0}
    // 0011 -> Subset {0, 1}
    // 0111 -> Subset {0, 1, 2}
    // 1111 -> Subset {0, 1, 2, 3}

    for (int i = 0; i < n; i++) {

      // Check if place i is included in the current subset mask.
      // This is done by checking if the i-th bit in mask is set.

      if ((mask & (1 << i)) != 0) {

        // If i is in the subset, try to calculate the cost of ending at i.

        for (int j = 0; j < n; j++) {

          // Explore all other places j in the subset to determine
          // the optimal path to reach place i.

          if (i != j && (mask & (1 << j)) != 0) {

            // Ensure i is not the same as j (no self-loops)
            // and place j is also in the subset.

            // Update dp[mask][i]:
            // Minimum cost of reaching i by considering the cost of
            // traveling from j to i and the best cost of reaching j
            // without visiting i.

            dp[mask][i] = min(
                dp[mask][i],
                dp[mask ^ (1 << i)][j] + distances[j]![i]!
            );
            //
            // If mask = 0111 (Subset {0, 1, 2}), i = 2, j = 1:
            // dp[0111][2] = min(dp[0111][2], dp[0011][1] + distances[1][2])
            //
            // mask ^ (1 << i) removes i from the subset.
            // Ex.:
            // mask = 0111 (Subset {0, 1, 2})
            // i = 2 (Place 2)
            // mask ^ (1 << 2) = 0011 (Subset {0, 1})
          }
        }
      }
    }
  }

  // Step 5: All places visited: Final mask is allVisitedMask.
  int allVisitedMask = (1 << n) - 1; // ex: If n = 4, allVisitedMask = 1111.

  // Step 6: Compute the minimum cost to visit all places.
  double minCost = double.infinity;
  for (int i = 0; i < n; i++) {

    // Consider all places i as the last visited place.

    if (i != startPoint) {

      // Skip the start place as we cannot "end" at the start initially.

      if (returnToStart) {

        // If we need to return to the start place, add the cost of returning.

        minCost = min(
            minCost,
            dp[allVisitedMask][i] + distances[i]![startPoint]!
        );
      } else {

        // If not returning to the start place, just consider the path cost.

        minCost = min(
            minCost,
            dp[allVisitedMask][i]
        );
      }
    }
  }

  // Collect the path as a list of points
  // This is actually not needed for the solution, but it's a nice-to-have feature.
  pointsPath.add(startPoint);
  int mask = allVisitedMask;
  int last = startPoint;
  for (int i = 1; i < n; i++) {
    int next = -1;
    for (int j = 0; j < n; j++) {
      if ((mask & (1 << j)) != 0) {
        if (next == -1 || dp[mask][j] + distances[j]![last]! < dp[mask][next] + distances[next]![last]!) {
          next = j;
        }
      }
    }
    pointsPath.add(next);
    mask ^= 1 << next;
    last = next;
  }

  // Now add all the points to the path
  if (returnToStart) {
    pointsPath.add(startPoint);
  }

  // Step 7: Return the minimum cost as an integer.

  return minCost.toInt();
}

// Parse the input and compute shortest distances between all numbered nodes
Map<int, Map<int, int>> computeDistanceMatrix(Map<int, Point> nodes, Map<Point, int> grid) {

  // BFS to compute distances between nodes
  Map<int, Map<int, int>> distances = {};
  Map<int, Map<int, int>> paths = {};
  for (int start in nodes.keys) {
    distances[start] = _bfs(grid, nodes[start]!, nodes);
  }

  return distances;
}


// Breadth-First Search to calculate distances from one node to all others,
// it also stores the path to the nodes.
Map<int, int> _bfs(
    Map<Point, int> grid,
    Point start,
    Map<int, Point> nodes)
{
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

// A* to calculate path from one node to the other
List<Point> _dijkstra(Map<Point, int> grid, Point start, Point end) {
  Map<Point, GridEntry> visited = {start: GridEntry(0, null)};
  List<Point> queue = [start];

  while (queue.isNotEmpty) {
    queue.sort((a, b) => visited[a]!.distFromStart - visited[b]!.distFromStart);

    Point current = queue.removeAt(0);
    int currentDist = visited[current]!.distFromStart;

    if (current == end) {
      break;
    }

    for (var direction in [
      Point(0, 1),
      Point(1, 0),
      Point(0, -1),
      Point(-1, 0)
    ]) {
      Point next = Point(current.x + direction.x, current.y + direction.y);

      if (grid.containsKey(next) &&
          !visited.containsKey(next)) {
        visited[next] = GridEntry(currentDist + 1, current);
        queue.add(next);
      }
    }
  }

  // Extract path
  List<Point> path = [];
  Point? current = end;
  while (current != null) {
    path.add(current);
    current = visited[current]!.prevNode;
  }
  path = path.reversed.toList();
  return path;
}


int findMultiPointRoute(Map<int, Point> points, Map<Point, int> grid, bool returnToStart) {
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
  var pathPoints = <int>[];
  var minDist = heldKarp(distances, points.length, 0, returnToStart, pathPoints);

  return minDist;
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
    return findMultiPointRoute(data.nodePositions, data.grid, part2);
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
