module slot_grid_0006
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 }
pred grid0006 {
  all x0: T1, x1: T0 |
    (x0 in x1.r and x1 in x0.r) and (some (x0.r & x1.r)) and ((some x0.mark) and ((some x1.mark) and (some x0.mark)))
}
pred grid0006C {
  all y0: T1, y1: T0 |
    (y0 in y1.r and y1 in y0.r) and (some (y0.r & y1.r)) and ((some y1.mark) and (some y0.mark))
}
assert equivalent { grid0006 iff grid0006C }
check equivalent for 10 but 1..3 steps
