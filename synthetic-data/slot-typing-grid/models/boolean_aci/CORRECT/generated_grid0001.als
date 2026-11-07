module slot_grid_0001
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 }
pred grid0001 {
  all x0: T0, x1: T0 |
    (x0 in x1.r and x1 in x0.r) and (some (x0.r & x1.r)) and ((some x0.mark) and ((some x1.mark) and (some x0.mark)))
}
pred grid0001C {
  all y0: T0, y1: T0 |
    (y0 in y1.r and y1 in y0.r) and (some (y0.r & y1.r)) and ((some y1.mark) and (some y0.mark))
}
assert equivalent { grid0001 iff grid0001C }
check equivalent for 10 but 1..3 steps
