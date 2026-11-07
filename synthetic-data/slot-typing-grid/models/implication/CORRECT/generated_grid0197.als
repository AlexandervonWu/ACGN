module slot_grid_0197
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
sig T3 extends Root {}
sig T4 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 and some T3 and some T4 }
pred grid0197 {
  all x0: T4, x1: T3, x2: T0, x3: T2, x4: T3, x5: T1, x6: T0, x7: T1, x8: T2 |
    (x6 in x7.r and x7 in x2.r and x2 in x1.r and x1 in x8.r and x8 in x5.r and x5 in x4.r and x4 in x0.r and x0 in x3.r and x3 in x6.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r & x8.r)) and ((some x0.mark) implies (some x1.mark))
}
pred grid0197C {
  all y1: T3, y6: T0, y5: T1, y2: T0, y3: T2, y7: T1, y8: T2, y4: T3, y0: T4 |
    (y6 in y7.r and y7 in y2.r and y2 in y1.r and y1 in y8.r and y8 in y5.r and y5 in y4.r and y4 in y0.r and y0 in y3.r and y3 in y6.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r & y6.r & y7.r & y8.r)) and (not (some y0.mark) or (some y1.mark))
}
assert equivalent { grid0197 iff grid0197C }
check equivalent for 10 but 1..3 steps
