module slot_grid_0167
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
sig T3 extends Root {}
sig T4 extends Root {}
sig T5 extends Root {}
sig T6 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 and some T3 and some T4 and some T5 and some T6 }
pred grid0167 {
  all x0: T2, x1: T3, x2: T1, x3: T4, x4: T6, x5: T5, x6: T0, x7: T4 |
    (x0 in x3.r and x3 in x2.r and x2 in x7.r and x7 in x5.r and x5 in x1.r and x1 in x6.r and x6 in x4.r and x4 in x0.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r)) and ((some x0.mark) implies (some x1.mark))
}
pred grid0167C {
  all y1: T3, y7: T4, y4: T6, y0: T2, y5: T5, y6: T0, y3: T4, y2: T1 |
    (y0 in y3.r and y3 in y2.r and y2 in y7.r and y7 in y5.r and y5 in y1.r and y1 in y6.r and y6 in y4.r and y4 in y0.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r & y6.r & y7.r)) and (not (some y0.mark) or (some y1.mark))
}
assert equivalent { grid0167 iff grid0167C }
check equivalent for 10 but 1..3 steps
