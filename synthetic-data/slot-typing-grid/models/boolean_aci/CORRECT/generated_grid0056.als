module slot_grid_0056
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 }
pred grid0056 {
  all x0: T2, x1: T0, x2: T1, x3: T1, x4: T2 |
    (x4 in x3.r and x3 in x2.r and x2 in x1.r and x1 in x0.r and x0 in x4.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r)) and ((some x0.mark) and ((some x1.mark) and (some x0.mark)))
}
pred grid0056C {
  all y1: T0, y0: T2, y4: T2, y2: T1, y3: T1 |
    (y4 in y3.r and y3 in y2.r and y2 in y1.r and y1 in y0.r and y0 in y4.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r)) and ((some y1.mark) and (some y0.mark))
}
assert equivalent { grid0056 iff grid0056C }
check equivalent for 10 but 1..3 steps
