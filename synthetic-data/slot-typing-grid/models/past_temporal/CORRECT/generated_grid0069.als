module slot_grid_0069
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
sig T3 extends Root {}
sig T4 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 and some T3 and some T4 }
pred grid0069 {
  all x0: T0, x1: T1, x2: T3, x3: T4, x4: T2 |
    (x0 in x4.r and x4 in x3.r and x3 in x2.r and x2 in x1.r and x1 in x0.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r)) and (once x0 in Live implies always x0 in Live)
}
pred grid0069C {
  all y3: T4, y2: T3, y0: T0, y4: T2, y1: T1 |
    (y0 in y4.r and y4 in y3.r and y3 in y2.r and y2 in y1.r and y1 in y0.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r)) and (once y0 in Live implies always y0 in Live)
}
assert equivalent { grid0069 iff grid0069C }
check equivalent for 10 but 1..3 steps
