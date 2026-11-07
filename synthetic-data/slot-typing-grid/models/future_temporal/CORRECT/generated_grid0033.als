module slot_grid_0033
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 }
pred grid0033 {
  all x0: T0, x1: T1, x2: T1, x3: T0 |
    (x2 in x1.r and x1 in x3.r and x3 in x0.r and x0 in x2.r) and (some (x0.r & x1.r & x2.r & x3.r)) and (always (x0 in Live implies eventually x1 in Live))
}
pred grid0033C {
  all y2: T1, y0: T0, y3: T0, y1: T1 |
    (y2 in y1.r and y1 in y3.r and y3 in y0.r and y0 in y2.r) and (some (y0.r & y1.r & y2.r & y3.r)) and (always (y0 in Live implies eventually y1 in Live))
}
assert equivalent { grid0033 iff grid0033C }
check equivalent for 10 but 1..3 steps
