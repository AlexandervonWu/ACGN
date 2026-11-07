module slot_grid_0149
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 }
pred grid0149 {
  all x0: T1, x1: T1, x2: T2, x3: T2, x4: T0, x5: T1, x6: T2, x7: T0 |
    (x3 in x6.r and x6 in x1.r and x1 in x2.r and x2 in x4.r and x4 in x5.r and x5 in x0.r and x0 in x7.r and x7 in x3.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r)) and (once x0 in Live implies always x0 in Live)
}
pred grid0149C {
  all y0: T1, y6: T2, y1: T1, y7: T0, y3: T2, y2: T2, y5: T1, y4: T0 |
    (y3 in y6.r and y6 in y1.r and y1 in y2.r and y2 in y4.r and y4 in y5.r and y5 in y0.r and y0 in y7.r and y7 in y3.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r & y6.r & y7.r)) and (once y0 in Live implies always y0 in Live)
}
assert equivalent { grid0149 iff grid0149C }
check equivalent for 10 but 1..3 steps
