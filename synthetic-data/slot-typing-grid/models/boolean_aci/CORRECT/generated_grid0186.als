module slot_grid_0186
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 }
pred grid0186 {
  all x0: T2, x1: T0, x2: T1, x3: T0, x4: T1, x5: T2, x6: T1, x7: T2, x8: T0 |
    (x7 in x1.r and x1 in x3.r and x3 in x2.r and x2 in x5.r and x5 in x0.r and x0 in x4.r and x4 in x6.r and x6 in x8.r and x8 in x7.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r & x8.r)) and ((some x0.mark) and ((some x1.mark) and (some x0.mark)))
}
pred grid0186C {
  all y4: T1, y3: T0, y7: T2, y5: T2, y2: T1, y8: T0, y6: T1, y1: T0, y0: T2 |
    (y7 in y1.r and y1 in y3.r and y3 in y2.r and y2 in y5.r and y5 in y0.r and y0 in y4.r and y4 in y6.r and y6 in y8.r and y8 in y7.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r & y6.r & y7.r & y8.r)) and ((some y1.mark) and (some y0.mark))
}
assert equivalent { grid0186 iff grid0186C }
check equivalent for 10 but 1..3 steps
