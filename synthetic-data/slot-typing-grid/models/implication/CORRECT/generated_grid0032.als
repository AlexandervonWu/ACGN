module slot_grid_0032
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 }
pred grid0032 {
  all x0: T1, x1: T0, x2: T1, x3: T0 |
    (x3 in x0.r and x0 in x2.r and x2 in x1.r and x1 in x3.r) and (some (x0.r & x1.r & x2.r & x3.r)) and ((some x0.mark) implies (some x1.mark))
}
pred grid0032C {
  all y3: T0, y0: T1, y1: T0, y2: T1 |
    (y3 in y0.r and y0 in y2.r and y2 in y1.r and y1 in y3.r) and (some (y0.r & y1.r & y2.r & y3.r)) and (not (some y0.mark) or (some y1.mark))
}
assert equivalent { grid0032 iff grid0032C }
check equivalent for 10 but 1..3 steps
