module slot_grid_0093
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
sig T3 extends Root {}
sig T4 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 and some T3 and some T4 }
pred grid0093 {
  all x0: T2, x1: T3, x2: T4, x3: T2, x4: T1, x5: T0 |
    (x1 in x3.r and x3 in x5.r and x5 in x4.r and x4 in x2.r and x2 in x0.r and x0 in x1.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r)) and (always (x0 in Live implies eventually x1 in Live))
}
pred grid0093C {
  all y3: T2, y1: T3, y2: T4, y5: T0, y0: T2, y4: T1 |
    (y1 in y3.r and y3 in y5.r and y5 in y4.r and y4 in y2.r and y2 in y0.r and y0 in y1.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r)) and (always (y0 in Live implies eventually y1 in Live))
}
assert equivalent { grid0093 iff grid0093C }
check equivalent for 10 but 1..3 steps
