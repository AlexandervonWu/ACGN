module slot_grid_0059
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 }
pred grid0059 {
  all x0: T1, x1: T2, x2: T1, x3: T0, x4: T0 |
    (x0 in x4.r and x4 in x3.r and x3 in x2.r and x2 in x1.r and x1 in x0.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r)) and (once x0 in Live implies always x0 in Live)
}
pred grid0059C {
  all y3: T0, y2: T1, y0: T1, y4: T0, y1: T2 |
    (y0 in y4.r and y4 in y3.r and y3 in y2.r and y2 in y1.r and y1 in y0.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r)) and (once y0 in Live implies always y0 in Live)
}
assert equivalent { grid0059 iff grid0059C }
check equivalent for 10 but 1..3 steps
