module slot_grid_0173
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
sig T3 extends Root {}
sig T4 extends Root {}
sig T5 extends Root {}
sig T6 extends Root {}
sig T7 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 and some T3 and some T4 and some T5 and some T6 and some T7 }
pred grid0173 {
  all x0: T4, x1: T3, x2: T0, x3: T2, x4: T5, x5: T6, x6: T1, x7: T7 |
    (x1 in x7.r and x7 in x6.r and x6 in x0.r and x0 in x4.r and x4 in x2.r and x2 in x5.r and x5 in x3.r and x3 in x1.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r)) and (always (x0 in Live implies eventually x1 in Live))
}
pred grid0173C {
  all y6: T1, y4: T5, y2: T0, y3: T2, y7: T7, y1: T3, y0: T4, y5: T6 |
    (y1 in y7.r and y7 in y6.r and y6 in y0.r and y0 in y4.r and y4 in y2.r and y2 in y5.r and y5 in y3.r and y3 in y1.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r & y6.r & y7.r)) and (always (y0 in Live implies eventually y1 in Live))
}
assert equivalent { grid0173 iff grid0173C }
check equivalent for 10 but 1..3 steps
