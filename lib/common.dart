import 'dart:convert';
import 'dart:io';

final int maxInt = (double.infinity is int) ? double.infinity as int : ~minInt;
final int minInt = (double.infinity is int) ? -double.infinity as int : (-1 << 63);

int getIntFromFile(String s, int i) {
  return int.parse(LineSplitter().convert(File(s).readAsStringSync())[i]);
}

String getStringFromFile(String s, int start, {int end = -1}) {
  var res = "";
  var list = LineSplitter().convert(File(s).readAsStringSync());
  if (end == -1) {
    end = start+1;
  }
  for (var i = start; i < end; ++i) {
    if (i > start) {
      res += "\n";
    }
    res += list[i];
  }
  return res;
}


