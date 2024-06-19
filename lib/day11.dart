import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:adventofcode_2016/day.dart';
import 'package:adventofcode_2016/solution_check.dart';
import 'package:collection/collection.dart';

import 'common.dart';

enum DeviceType {
  generator, microchip
}

class Device {
  final DeviceType type;
  final String name;
  bool disabled = false; // used as opt. for quick calculation of unique id
  Device(this.type, this.name);

  Device clone() {
    return Device(this.type, this.name);
  }

  String shortName() {
    String shortName = name.toUpperCase().substring(0, 1);
    String symbol = type == DeviceType.generator ? "G" : "M";
    return shortName + symbol;
  }

  // THE MOST IMPORTANT, ABSOLUTELY ESSENTIAL: ALL PAIRS ARE INTERCHANGEABLE
  String shortDevName() {
    String symbol = type == DeviceType.generator ? "G" : "M";
    return symbol;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Device &&
              runtimeType == other.runtimeType &&
              type == other.type
  //&&
  // name == other.name
      ;

  @override
  int get hashCode => (17 + type.index) ^ name.hashCode;

  @override
  String toString() {
    return shortName();
  }
}

class Floor {
  final List<Device> devices = [];

  Floor clone() {
    Floor newFloor = Floor();
    for (Device device in devices) {
      newFloor.devices.add(device.clone());
    }
    return newFloor;
  }

  void resetDisabledDevices() {
    for (var device in devices) {
      device.disabled = false;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Floor &&
              runtimeType == other.runtimeType &&
              ListEquality().equals(devices, other.devices)
  ;

  @override
  int get hashCode {
    int result = 17;
    int sumHash = 0;
    for (var device in devices) {
      sumHash += device.hashCode;
      result = result ^ device.hashCode;
    }
    result = 37 * result + sumHash;
    return result;
  }

  @override
  String toString() {
    return devices.toList().sorted((a, b) => a.shortName().compareTo(b.shortName()))
        .fold("", (previousValue, element) => previousValue + (previousValue.isEmpty ? "" : ",") + "$element");
  }
}

List<Floor> deepCopyBuilding(List<Floor> building) {
  return building.map((floor) => floor.clone()).toList();
}

class Task {
  final List<Floor> building;
  Task? prevTask;
  int step = 0;
  int elevatorFloor = 0;
  Task(this.step, this.elevatorFloor, this.building, this.prevTask);

  void resetDisabledDevices() {
    for (var floor in building) {
      floor.resetDisabledDevices();
    }
  }

  // Helper function to print the floor status in a given format
  String floorToString(Floor floor, int floorNumber, bool withElevator, List<Device> devicePositions) {

    // Creating a list for each type of device found on the floor
    StringBuffer sb = StringBuffer();

    // Set symbols for devices on this floor
    for (var i = 0; i < devicePositions.length; ++i) {
      var dev = devicePositions[i];
      if (floor.devices.contains(dev))
        sb.write("${dev.shortName()} ");
      else
        sb.write(".  ");
    }

    return 'F${5-floorNumber} ${withElevator ? "E " : ". "} ${sb.toString()}';
  }
  /*
F4 .  .  .  .  .
F3 .  .  .  LG .
F2 .  HG .  .  .
F1 E  .  HM .  LM

F4 .  .  .  .  .
F3 .  .  .  LG .
F2 .  HG .  .  .
F1 E  .  HM .  LM
   */
  // Function to print the entire building state
  void printBuilding(String log) {
    List<Device> allDevices = [];
    for (var floor in building) {
      for (var dev in floor.devices)
        allDevices.add(dev);
    }
    allDevices.sort((dev1, dev2) {
      int comparison = dev1.name.compareTo(dev2.name);
      if (comparison == 0) {
        return dev1.type.index - dev2.type.index;
      }
      return comparison;
    });

    print("\n$log");
    for (int i = building.length - 1; i >= 0; i--) {
      print(floorToString(building[i], building.length-i, elevatorFloor == i, allDevices));
    }
  }

  static Set<String> chips = {};
  static Set<String> generators = {};

  bool isValidState() {
    for (var floor in building) {
      chips.clear();
      generators.clear();
      for (var d in floor.devices) {
        if (d.type == DeviceType.microchip) {
          chips.add(d.name);
        }
        if (d.type == DeviceType.generator) {
          generators.add(d.name);
        }
      }
      if ((chips.difference(generators)).isNotEmpty && generators.length != 0)
        return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'Task{step: $step, elevator: $elevatorFloor, hash: $hashCode, uid: ${getUniqueId()}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          hashCode == other.hashCode &&
              other is Task &&
              runtimeType == other.runtimeType &&
              ListEquality().equals(building, other.building) &&
              //step == other.step &&
              elevatorFloor == other.elevatorFloor;

  @override
  int get hashCode {
    int result = 17;
    for (var floor in building) {
      result = 37 * result + floor.hashCode;
    }
    //result = 37 * result + step.hashCode;
    result = 37 * result + elevatorFloor * 17;
    return result;
  }

  static StringBuffer sb = StringBuffer();
  static StringBuffer sb2 = StringBuffer();

  // Calculates always unique id of all floors and elevator
  String getUniqueId([int nextElevatorFloor = -1, Device? device = null, Device? device2 = null]) {
    sb.clear();
    sb2.clear();
    for (var f = 0; f < building.length; ++f) {
      var floor = building[f];
      sb.write("_");

      sb2.clear();
      for (var i = 0; i < floor.devices.length; ++i) {
        var dev = floor.devices[i];
        if (dev.disabled)
          continue;
        sb2.write(dev.shortDevName());
      }

      if (nextElevatorFloor == f) {
        if (device != null) {
          sb2.write(device.shortDevName());
        }
        if (device2 != null) {
          sb2.write(device2.shortDevName());
        }
      }

      sb.write((sb2.toString().split('')..sort()).join(''));
    }
    sb.write("_");
    sb.write(nextElevatorFloor != -1 ? nextElevatorFloor : elevatorFloor);
    return sb.toString();
  }
}

int taskComparator(Task t1, Task t2) {
  /*
  // Below commented gives nothing, it was supposed to prioritize the moves
  // with more devices on the top floors.
  if (t1.step == t2.step) {
    if (t1.elevatorFloor == t2.elevatorFloor) {
      if (t2.building[3].devices.length == t1.building[3].devices.length) {
        if (t2.building[2].devices.length == t1.building[2].devices.length)
          return t2.building[1].devices.length - t1.building[1].devices.length;
        return t2.building[2].devices.length - t1.building[2].devices.length;
      }
      return t2.building[3].devices.length - t1.building[3].devices.length;
    }
    else
      return t2.elevatorFloor - t1.elevatorFloor;
  }
  */
  return t1.step.compareTo(t2.step);
}

class Day11 extends Day with ProblemReader, SolutionCheck {
  static dynamic readData(var filePath) {
    return  parseData(File(filePath).readAsStringSync());
  }

  static List<Floor> parseData(String data) {
    /*
    The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
    The second floor contains a hydrogen generator.
    The third floor contains a lithium generator.
    The fourth floor contains nothing relevant.
    */
    List<Floor> building = List.generate(4, (index) => Floor());

    int ind = 0; // floor indicator

    // iterate each floor
    for (var line in LineSplitter().convert(data)) {

      // Split into ex: "The first floor" "a hydrogen-compatible microchip and a lithium-compatible microchip."
      // where only second element is of interrest.
      var ln2 = line.split("contains")[1].trim().replaceAll(".", "");

      // Now split: "a hydrogen-compatible microchip and a lithium-compatible microchip" into:
      //     "a hydrogen-compatible microchip" "a lithium-compatible microchip"
      // or in different version:
      //     "a cobalt generator, a curium generator, a ruthenium generator, and a plutonium generator.
      var ln3 = ln2.split(RegExp(r"\s*(?:and|,)\s*")).where((s) => s.isNotEmpty).toList();

      //this is an empty floor
      if (ln3.contains("nothing relevant")) {
        break;
      }

      var rg = RegExp(r"(and )?a (?<element>\w+)(-compatible)? (?<device_type>\w+)");
      for (var devItem in ln3) {
        var m = rg.firstMatch(devItem)!;
        var elementNameString = m.namedGroup("element")!;
        var deviceTypeString = m.namedGroup("device_type")!;
        var deviceType = DeviceType.values.byName(deviceTypeString);
        building[ind].devices.add(Device(deviceType, elementNameString));
      }

      ind++;
    }
    ind++;

    return building;
  }

  int countDevices(List<Floor> building) {
    int count = 0;
    for (var f in building) {
      count += f.devices.length;
    }
    return count;
  }

  HashSet<String> cache = HashSet();

  void makeMoves(PriorityQueue<Task> queue, Task startTask) {

    int elevatorFloor = startTask.elevatorFloor;
    var currentFloor = startTask.building[elevatorFloor].devices;

    for (int nextElevatorFloorIndex = 0; nextElevatorFloorIndex <= 1; ++nextElevatorFloorIndex) {
      int nextElevatorFloor = elevatorFloor + (nextElevatorFloorIndex == 0 ? 1 : -1);
      if (nextElevatorFloor < 0 || nextElevatorFloor >= startTask.building.length)
        continue;

      if (elevatorFloor == 1 && nextElevatorFloor == 0 && startTask.building[0].devices.isEmpty) {
        continue;
      }
      if (elevatorFloor == 2 && nextElevatorFloor == 1 && startTask.building[0].devices.isEmpty && startTask.building[1].devices.isEmpty) {
        continue;
      }

      for (int n = 0; n < currentFloor.length; ++n) {
        var device1 = currentFloor[n];

        // Quick calculate unique id, minimal allocations.
        startTask.building[elevatorFloor].devices[n].disabled = true;
        var testUniqueId = startTask.getUniqueId(nextElevatorFloor, device1);
        startTask.building[elevatorFloor].devices[n].disabled = false;

        if (!cache.contains(testUniqueId)) {

          // Single move
          Task t = Task(startTask.step + 1, nextElevatorFloor, deepCopyBuilding(startTask.building), startTask);
          t.building[elevatorFloor].devices.removeAt(n);

          t.building[nextElevatorFloor].devices.add(device1);
          t.building[nextElevatorFloor].devices.sort((a, b) =>
              a.shortDevName().compareTo(b.shortDevName()));

          if (t.isValidState()) {
            //assert(testUniqueId == t.getUniqueId());
            cache.add(testUniqueId);
            queue.add(t);
          }
        }

        // Two devices move
        for (int k = n+1; k < currentFloor.length; ++k) {
          var device2 = currentFloor[k];

          // Quick calculate unique id, minimal allocations.
          startTask.building[elevatorFloor].devices[n].disabled = true;
          startTask.building[elevatorFloor].devices[k].disabled = true;
          var testUniqueId = startTask.getUniqueId(
              nextElevatorFloor, device1, device2);
          startTask.building[elevatorFloor].devices[n].disabled = false;
          startTask.building[elevatorFloor].devices[k].disabled = false;

          if (!cache.contains(testUniqueId)) {

            // Two devices move
            Task t = Task(startTask.step + 1, nextElevatorFloor,
                deepCopyBuilding(startTask.building), startTask);
            t.building[elevatorFloor].devices.removeAt(k);
            t.building[elevatorFloor].devices.removeAt(n);

            t.building[nextElevatorFloor].devices.add(device1);
            t.building[nextElevatorFloor].devices.add(device2);
            t.building[nextElevatorFloor].devices.sort((a, b) =>
                a.shortDevName().compareTo(b.shortDevName()));

            if (t.isValidState()) {
              //assert(testUniqueId == t.getUniqueId());
              cache.add(testUniqueId);
              queue.add(t);
            }
          }
        }
      }
    }
  }

  bool isFinalTask(Task task) {
    for (int k = 0; k < task.building.length - 1; ++k)
      if (task.building[k].devices.isNotEmpty)
        return false;
    return true;
  }

  Future<int> solve(List<Floor> data, {var part2 = false}) async {

    if (part2) {
      data[0].devices.add(Device(DeviceType.generator, "elerium"));
      data[0].devices.add(Device(DeviceType.microchip, "elerium"));
      data[0].devices.add(Device(DeviceType.generator, "dilithium"));
      data[0].devices.add(Device(DeviceType.microchip, "dilithium"));
    }

    var queue = PriorityQueue<Task>(taskComparator);
    int minSteps = 9999999;

    var startTask = new Task(0, 0, data, null);
    queue.add(startTask);
    cache.add(startTask.getUniqueId());

    int queueMaxSize = -1;

    while (queue.isNotEmpty) {
      if (queue.length > queueMaxSize) {
        queueMaxSize = queue.length;
      }
      var task = queue.removeFirst();

      if (task.step+1 >= minSteps)
        continue;

      if (isFinalTask(task)) {
        if (task.step < minSteps) {
          minSteps = task.step;
        }
        continue;
      }

      makeMoves(queue, task);
    }

    //print("Queue size: $queueMaxSize");

    return minSteps;
  }

  @override
  Future<void> run() async {
    print("Day11");

    var data = readData("../adventofcode_input/2016/data/day11.txt");

    var res1 = await solve(data);
    print('Part1: $res1');
    verifyResult(res1, getIntFromFile("../adventofcode_input/2016/data/day11_results.txt", 0));

    var res2 = await solve(data, part2: true);
    print('Part2: $res2');
    verifyResult(res2, getIntFromFile("../adventofcode_input/2016/data/day11_results.txt", 1));
  }

}