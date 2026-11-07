module slot_grid_0234
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 }
pred grid0234 {
  all x0: T1, x1: T2, x2: T0, x3: T1, x4: T2, x5: T2, x6: T0, x7: T0, x8: T1, x9: T0 |
    (x2 in x8.r and x8 in x4.r and x4 in x9.r and x9 in x6.r and x6 in x0.r and x0 in x7.r and x7 in x3.r and x3 in x5.r and x5 in x1.r and x1 in x2.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r & x8.r & x9.r)) and (once x0 in Live implies always x0 in Live)
}
pred grid0234C {
  all y2: T0, y0: T1, y8: T1, y1: T2, y6: T0, y5: T2, y4: T2, y3: T1, y7: T0, y9: T0 |
    (y2 in y8.r and y8 in y4.r and y4 in y9.r and y9 in y6.r and y6 in y0.r and y0 in y7.r and y7 in y3.r and y3 in y5.r and y5 in y1.r and y1 in y2.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r & y6.r & y7.r & y8.r & y9.r)) and (once y0 in Live implies always y0 in Live)
}
assert equivalent { grid0234 iff grid0234C }
check equivalent for 10 but 1..3 steps
