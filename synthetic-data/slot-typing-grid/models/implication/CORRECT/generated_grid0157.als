module slot_grid_0157
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
sig T3 extends Root {}
sig T4 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 and some T3 and some T4 }
pred grid0157 {
  all x0: T2, x1: T1, x2: T3, x3: T2, x4: T1, x5: T0, x6: T4, x7: T0 |
    (x0 in x3.r and x3 in x2.r and x2 in x7.r and x7 in x5.r and x5 in x1.r and x1 in x6.r and x6 in x4.r and x4 in x0.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r)) and ((some x0.mark) implies (some x1.mark))
}
pred grid0157C {
  all y1: T1, y7: T0, y4: T1, y0: T2, y5: T0, y6: T4, y3: T2, y2: T3 |
    (y0 in y3.r and y3 in y2.r and y2 in y7.r and y7 in y5.r and y5 in y1.r and y1 in y6.r and y6 in y4.r and y4 in y0.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r & y6.r & y7.r)) and (not (some y0.mark) or (some y1.mark))
}
assert equivalent { grid0157 iff grid0157C }
check equivalent for 10 but 1..3 steps
