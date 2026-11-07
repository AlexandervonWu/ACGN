module slot_grid_0040
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
sig T3 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 and some T3 }
pred grid0040 {
  all x0: T3, x1: T0, x2: T2, x3: T1 |
    (x0 in x2.r and x2 in x3.r and x3 in x1.r and x1 in x0.r) and (some (x0.r & x1.r & x2.r & x3.r)) and (some x0.mark)
}
pred grid0040C {
  all y0: T3, y2: T2, y3: T1, y1: T0 |
    (y0 in y2.r and y2 in y3.r and y3 in y1.r and y1 in y0.r) and (some (y0.r & y1.r & y2.r & y3.r)) and (some y0.mark)
}
assert equivalent { grid0040 iff grid0040C }
check equivalent for 10 but 1..3 steps
