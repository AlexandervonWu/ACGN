module slot_grid_0023
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 }
pred grid0023 {
  all x0: T0, x1: T2, x2: T1 |
    (x0 in x2.r and x2 in x1.r and x1 in x0.r) and (some (x0.r & x1.r & x2.r)) and (always (x0 in Live implies eventually x1 in Live))
}
pred grid0023C {
  all y2: T1, y1: T2, y0: T0 |
    (y0 in y2.r and y2 in y1.r and y1 in y0.r) and (some (y0.r & y1.r & y2.r)) and (always (y0 in Live implies eventually y1 in Live))
}
assert equivalent { grid0023 iff grid0023C }
check equivalent for 10 but 1..3 steps
