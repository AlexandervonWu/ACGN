module slot_grid_0090
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
sig T3 extends Root {}
sig T4 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 and some T3 and some T4 }
pred grid0090 {
  all x0: T3, x1: T1, x2: T4, x3: T3, x4: T0, x5: T2 |
    (x3 in x4.r and x4 in x2.r and x2 in x1.r and x1 in x0.r and x0 in x5.r and x5 in x3.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r)) and (some x0.mark)
}
pred grid0090C {
  all y1: T1, y3: T3, y2: T4, y4: T0, y5: T2, y0: T3 |
    (y3 in y4.r and y4 in y2.r and y2 in y1.r and y1 in y0.r and y0 in y5.r and y5 in y3.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r)) and (some y0.mark)
}
assert equivalent { grid0090 iff grid0090C }
check equivalent for 10 but 1..3 steps
