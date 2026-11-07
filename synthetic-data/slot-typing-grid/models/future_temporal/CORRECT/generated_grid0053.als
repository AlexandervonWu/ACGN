module slot_grid_0053
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 }
pred grid0053 {
  all x0: T0, x1: T1, x2: T1, x3: T0, x4: T1 |
    (x4 in x1.r and x1 in x0.r and x0 in x3.r and x3 in x2.r and x2 in x4.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r)) and (always (x0 in Live implies eventually x1 in Live))
}
pred grid0053C {
  all y2: T1, y0: T0, y1: T1, y4: T1, y3: T0 |
    (y4 in y1.r and y1 in y0.r and y0 in y3.r and y3 in y2.r and y2 in y4.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r)) and (always (y0 in Live implies eventually y1 in Live))
}
assert equivalent { grid0053 iff grid0053C }
check equivalent for 10 but 1..3 steps
