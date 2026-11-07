module slot_grid_0143
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 }
pred grid0143 {
  all x0: T0, x1: T0, x2: T0, x3: T1, x4: T0, x5: T1, x6: T1, x7: T1 |
    (x1 in x7.r and x7 in x6.r and x6 in x0.r and x0 in x4.r and x4 in x2.r and x2 in x5.r and x5 in x3.r and x3 in x1.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r)) and (always (x0 in Live implies eventually x1 in Live))
}
pred grid0143C {
  all y6: T1, y4: T0, y2: T0, y3: T1, y7: T1, y1: T0, y0: T0, y5: T1 |
    (y1 in y7.r and y7 in y6.r and y6 in y0.r and y0 in y4.r and y4 in y2.r and y2 in y5.r and y5 in y3.r and y3 in y1.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r & y6.r & y7.r)) and (always (y0 in Live implies eventually y1 in Live))
}
assert equivalent { grid0143 iff grid0143C }
check equivalent for 10 but 1..3 steps
