module slot_grid_0007
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 }
pred grid0007 {
  all x0: T0, x1: T1 |
    (x1 in x0.r and x0 in x1.r) and (some (x0.r & x1.r)) and ((some x0.mark) implies (some x1.mark))
}
pred grid0007C {
  all y0: T0, y1: T1 |
    (y1 in y0.r and y0 in y1.r) and (some (y0.r & y1.r)) and (not (some y0.mark) or (some y1.mark))
}
assert equivalent { grid0007 iff grid0007C }
check equivalent for 10 but 1..3 steps
