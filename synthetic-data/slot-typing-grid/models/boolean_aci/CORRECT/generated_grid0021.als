module slot_grid_0021
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 }
pred grid0021 {
  all x0: T0, x1: T2, x2: T1 |
    (x1 in x0.r and x0 in x2.r and x2 in x1.r) and (some (x0.r & x1.r & x2.r)) and ((some x0.mark) and ((some x1.mark) and (some x0.mark)))
}
pred grid0021C {
  all y2: T1, y1: T2, y0: T0 |
    (y1 in y0.r and y0 in y2.r and y2 in y1.r) and (some (y0.r & y1.r & y2.r)) and ((some y1.mark) and (some y0.mark))
}
assert equivalent { grid0021 iff grid0021C }
check equivalent for 10 but 1..3 steps
