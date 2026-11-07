module slot_grid_0017
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 }
pred grid0017 {
  all x0: T1, x1: T0, x2: T0 |
    (x0 in x2.r and x2 in x1.r and x1 in x0.r) and (some (x0.r & x1.r & x2.r)) and ((some x0.mark) implies (some x1.mark))
}
pred grid0017C {
  all y2: T0, y0: T1, y1: T0 |
    (y0 in y2.r and y2 in y1.r and y1 in y0.r) and (some (y0.r & y1.r & y2.r)) and (not (some y0.mark) or (some y1.mark))
}
assert equivalent { grid0017 iff grid0017C }
check equivalent for 10 but 1..3 steps
