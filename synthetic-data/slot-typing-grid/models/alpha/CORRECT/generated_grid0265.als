module slot_grid_0265
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
sig T3 extends Root {}
sig T4 extends Root {}
sig T5 extends Root {}
sig T6 extends Root {}
sig T7 extends Root {}
sig T8 extends Root {}
sig T9 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 and some T3 and some T4 and some T5 and some T6 and some T7 and some T8 and some T9 }
pred grid0265 {
  all x0: T6, x1: T2, x2: T0, x3: T7, x4: T5, x5: T1, x6: T4, x7: T3, x8: T9, x9: T8 |
    (x8 in x1.r and x1 in x2.r and x2 in x5.r and x5 in x6.r and x6 in x3.r and x3 in x7.r and x7 in x4.r and x4 in x9.r and x9 in x0.r and x0 in x8.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r & x8.r & x9.r)) and (some x0.mark)
}
pred grid0265C {
  all y8: T9, y4: T5, y1: T2, y6: T4, y2: T0, y7: T3, y5: T1, y0: T6, y3: T7, y9: T8 |
    (y8 in y1.r and y1 in y2.r and y2 in y5.r and y5 in y6.r and y6 in y3.r and y3 in y7.r and y7 in y4.r and y4 in y9.r and y9 in y0.r and y0 in y8.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r & y6.r & y7.r & y8.r & y9.r)) and (some y0.mark)
}
assert equivalent { grid0265 iff grid0265C }
check equivalent for 10 but 1..3 steps
