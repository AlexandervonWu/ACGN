module slot_grid_0009
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 }
pred grid0009 {
  all x0: T0, x1: T1 |
    (x0 in x1.r and x1 in x0.r) and (some (x0.r & x1.r)) and (once x0 in Live implies always x0 in Live)
}
pred grid0009C {
  all y0: T0, y1: T1 |
    (y0 in y1.r and y1 in y0.r) and (some (y0.r & y1.r)) and (once y0 in Live implies always y0 in Live)
}
assert equivalent { grid0009 iff grid0009C }
check equivalent for 10 but 1..3 steps
