module slot_grid_0170
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
pred grid0170 {
  all x0: T1, x1: T7, x2: T3, x3: T0, x4: T2, x5: T4, x6: T5, x7: T6 |
    (x2 in x6.r and x6 in x0.r and x0 in x3.r and x3 in x5.r and x5 in x4.r and x4 in x7.r and x7 in x1.r and x1 in x2.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r)) and (some x0.mark)
}
pred grid0170C {
  all y4: T2, y3: T0, y6: T5, y5: T4, y2: T3, y1: T7, y0: T1, y7: T6 |
    (y2 in y6.r and y6 in y0.r and y0 in y3.r and y3 in y5.r and y5 in y4.r and y4 in y7.r and y7 in y1.r and y1 in y2.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r & y6.r & y7.r)) and (some y0.mark)
}
assert equivalent { grid0170 iff grid0170C }
check equivalent for 10 but 1..3 steps
