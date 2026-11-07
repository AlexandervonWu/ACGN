module slot_grid_0052
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 }
pred grid0052 {
  all x0: T0, x1: T0, x2: T0, x3: T1, x4: T1 |
    (x2 in x4.r and x4 in x0.r and x0 in x1.r and x1 in x3.r and x3 in x2.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r)) and ((some x0.mark) implies (some x1.mark))
}
pred grid0052C {
  all y0: T0, y2: T0, y3: T1, y4: T1, y1: T0 |
    (y2 in y4.r and y4 in y0.r and y0 in y1.r and y1 in y3.r and y3 in y2.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r)) and (not (some y0.mark) or (some y1.mark))
}
assert equivalent { grid0052 iff grid0052C }
check equivalent for 10 but 1..3 steps
