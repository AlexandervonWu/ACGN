module slot_grid_0051
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 }
pred grid0051 {
  all x0: T1, x1: T0, x2: T0, x3: T0, x4: T1 |
    (x4 in x3.r and x3 in x2.r and x2 in x1.r and x1 in x0.r and x0 in x4.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r)) and ((some x0.mark) and ((some x1.mark) and (some x0.mark)))
}
pred grid0051C {
  all y1: T0, y0: T1, y4: T1, y2: T0, y3: T0 |
    (y4 in y3.r and y3 in y2.r and y2 in y1.r and y1 in y0.r and y0 in y4.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r)) and ((some y1.mark) and (some y0.mark))
}
assert equivalent { grid0051 iff grid0051C }
check equivalent for 10 but 1..3 steps
