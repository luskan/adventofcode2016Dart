2016 AdventOfCode in Dart

https://adventofcode.com/2016

[Day 22: Grid Computing](https://adventofcode.com/2016/day/22)
<br>
[Solution](lib/day22.dart) uses dijkstra for path finding, so it is very general. Too large nodes are treated as walls. Initially a path from G to [.] is computed. Then G is moved along it, but before each move an empty node is moved on the next position on the G-s way. Each time to move empty node to this position dijkistra is used. 
<br>
[.] - this is the node where G nodes data is to be moved
<br>
G - node with data which we want to move to [.]
<br>
. - nodes whose size of used data does not exceed the size of the empty node
<br>
\# blue - represents nodes whose size of used data exceeds the size of the empty node
<br>
_ - is the only empty node, used to move data
<br>
yellow blocks - are the paths along which the empty space is being moved
![Day 22: Grid Computing](/imgs/output.gif)