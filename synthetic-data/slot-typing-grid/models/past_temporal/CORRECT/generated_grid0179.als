module slot_grid_0179
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 }
pred grid0179 {
  all x0: T0, x1: T0, x2: T0, x3: T0, x4: T0, x5: T0, x6: T0, x7: T0, x8: T0 |
    (x7 in x8.r and x8 in x1.r and x1 in x0.r and x0 in x4.r and x4 in x2.r and x2 in x6.r and x6 in x5.r and x5 in x3.r and x3 in x7.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r & x8.r)) and (once x0 in Live implies always x0 in Live)
}
pred grid0179C {
  all y0: T0, y7: T0, y3: T0, y8: T0, y6: T0, y5: T0, y2: T0, y4: T0, y1: T0 |
    (y7 in y8.r and y8 in y1.r and y1 in y0.r and y0 in y4.r and y4 in y2.r and y2 in y6.r and y6 in y5.r and y5 in y3.r and y3 in y7.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r & y6.r & y7.r & y8.r)) and (once y0 in Live implies always y0 in Live)
}
assert equivalent { grid0179 iff grid0179C }
check equivalent for 10 but 1..3 steps
