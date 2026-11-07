module slot_grid_0024
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 }
pred grid0024 {
  all x0: T0, x1: T2, x2: T1 |
    (x2 in x1.r and x1 in x0.r and x0 in x2.r) and (some (x0.r & x1.r & x2.r)) and (once x0 in Live implies always x0 in Live)
}
pred grid0024C {
  all y1: T2, y2: T1, y0: T0 |
    (y2 in y1.r and y1 in y0.r and y0 in y2.r) and (some (y0.r & y1.r & y2.r)) and (once y0 in Live implies always y0 in Live)
}
assert equivalent { grid0024 iff grid0024C }
check equivalent for 10 but 1..3 steps
