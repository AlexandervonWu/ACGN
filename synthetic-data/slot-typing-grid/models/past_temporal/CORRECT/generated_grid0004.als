module slot_grid_0004
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 }
pred grid0004 {
  all x0: T0, x1: T0 |
    (x0 in x1.r and x1 in x0.r) and (some (x0.r & x1.r)) and (once x0 in Live implies always x0 in Live)
}
pred grid0004C {
  all y0: T0, y1: T0 |
    (y0 in y1.r and y1 in y0.r) and (some (y0.r & y1.r)) and (once y0 in Live implies always y0 in Live)
}
assert equivalent { grid0004 iff grid0004C }
check equivalent for 10 but 1..3 steps
