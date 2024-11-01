import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';
import 'package:collection/collection.dart';

import 'package:image/image.dart' as img;

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

  bool isLarge() => size > 100; // Its a node with very large data as used, it cannot be
                                // used to exchange data with empty, so we use it as a
                                // wall. Actually it should be calculated from the input.

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

  List<img.Image> frames = [];

  // Creates blinking artifacts, its better to generate each frame as png and
  // use imagemagick to create a gif.
  void saveGif(String filePath) {
    var animatedGif = img.GifEncoder();  // Create a GIF encoder
    for (var frame in frames) {
      // Ensure each frame is properly initialized
      var frameCopy = img.Image.from(frame);
      animatedGif.addFrame(frameCopy, duration: 100);  // Add each frame to the GIF
    }

    var gifData = animatedGif.finish();
    if (gifData != null) {
      File(filePath).writeAsBytesSync(gifData);
      print('GIF saved at $filePath');
    } else {
      print('Failed to create GIF');
    }
  }

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


  var maxX = -1;
  var maxY = -1;
  late img.BitmapFont font;

  void printMap(int id, Map<Point, DFEntry> entries, List<Point> path, Point emptyPtOverride, Point dataPtOverride) {
    var cellSize = 20; // Size of each cell in pixels

    if (maxX == -1) {
      maxX = entries.keys.reduce((value, element) => element.x > value.x ? element : value).x + 1;
      maxY = entries.keys.reduce((value, element) => element.y > value.y ? element : value).y + 1;
      font = img.BitmapFont.fromZip(File('fonts/Tahoma-Bold-14.ttf.zip').readAsBytesSync());
    }

    var width = (maxX+1) * cellSize;
    var height = (maxY+1) * cellSize;

    var image = img.Image(width, height);

    var emptyUsageNode = emptyPtOverride == null ? _findEmptyUsageEntry(entries).pt : emptyPtOverride;

    var printConsole = false;

    for (var y = 0; y <= maxY; ++y) {
      for (var x = 0; x <= maxX; ++x) {

        if (y == 0 && x == 0) {
          continue;
        }

        // If first row, then write 0 - 9 numbers
        if (y == 0 && x > 0) {
          var num = x - 1;
          var color = img.getColor(255, 255, 255); // White
          var extents = calculateTextExtent(num.toString(), font);
          var textX = (x * cellSize) + (cellSize ~/ 2) - (extents.$1 ~/ 2);
          var textY = (cellSize ~/ 2) - (extents.$2 ~/ 2);

          img.fillRect(image, (x) * cellSize, (y) * cellSize, (x+1) * cellSize, (y+1) * cellSize, img.getColor(128, 128, 128));

          img.drawString(
              image, font, textX, textY, num.toString(),
              color: color);

          continue;
        }

        // If first column, then write 0 - 9 numbers
        if (x == 0 && y > 0) {
          var num = y - 1;
          var color = img.getColor(255, 255, 255); // White
          var extents = calculateTextExtent(num.toString(), font);

          var textX = (cellSize ~/ 2) - (extents.$1 ~/ 2);
          var textY = (y * cellSize) + (cellSize ~/ 2) - (extents.$2 ~/ 2);

          img.fillRect(image, (x) * cellSize, (y) * cellSize, (x+1) * cellSize, (y+1) * cellSize, img.getColor(128, 128, 128));

          img.drawString(
              image, font, textX, textY, num.toString(),
              color: color);

          continue;
        }

        //if (!entries.containsKey(Point(x-1, y-1)))
        //  continue;

        var entry = entries[Point(x-1, y-1)]!;
        int color;
        String symbol = "";
        if (entry.x == 0 && entry.y == 0) {
          // Color for '0'
          color = img.getColor(108, 108, 108);
          symbol = "[.]";
        } else if (entry.x == dataPtOverride.x && entry.y == dataPtOverride.y) {
          // Color for 'G'
          color = img.getColor(108, 108, 108);
          symbol = "G";
        } else if (emptyUsageNode == entry.pt) {
          // Color for '_'
          color = img.getColor(0, 255, 0); // Green
          symbol = "_";
        } else if (entry.isLarge()) {
          // Color for '#'
          color = img.getColor(0, 0, 255); // Blue
          symbol = "#";
        } else {
          if (path.contains(entry.pt)) {
            // Color for '*'
            color = img.getColor(255, 255, 0); // Yellow
            if (printConsole)
              stdout.write("*");
          } else {
            // Color for '.'
            symbol = ".";
            color = img.getColor(128, 128, 128); // Gray
          }

        }


        if (printConsole)
          stdout.write(symbol);

        // Draw the cell onto the image
        img.fillRect(image, (x) * cellSize, (y) * cellSize, (x+1) * cellSize, (y+1) * cellSize, color);

        var extents = calculateTextExtent(symbol, font);
        var textX = ((x) * cellSize) + (cellSize ~/ 2) - (extents.$1 ~/ 2);
        var textY = ((y) * cellSize) + (cellSize ~/ 2) - (extents.$2 ~/ 2);
        img.drawString(image, font, textX, textY, symbol,
            color: img.getColor(255, 255, 255));

      }
      if (printConsole)
        stdout.write("\n");
    }

    if (printConsole) {
      stdout.write("\n");
      stdout.write("\n");
      stdout.write("\n");
    }

    // Saves pngs to create a gif with:
    // magick -delay 10 -loop 0 $(ls day*_map.png | sort -V) -compress LZW -layers optimize output.gif
    // Dart aproach (saveGif) creates many ugly artifacts.
    var encodedImage = img.PngEncoder().encodeImage(image);
    File('imgs/day${id.toString().padLeft(3, '0')}_map.png').writeAsBytesSync(encodedImage);

    // Add the image to the frames list
    frames.add(image);
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
      int id = 0;
      for (var dataPt in dataPath) {
        var path = _findPathUsingDijkstra(entries, emptyPt, dataPt, [prevDataPt]);

        /*
        for (var i = 0; i < path.length; ++i) {
          printMap(id++, entries, path, path[i], prevDataPt);
        }
        */

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

    // poor quality, better to use imagemagick
    //saveGif('day22_animation.gif');
  }
}