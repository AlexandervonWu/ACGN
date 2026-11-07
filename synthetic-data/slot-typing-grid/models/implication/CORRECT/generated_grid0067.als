module slot_grid_0067
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
sig T1 extends Root {}
sig T2 extends Root {}
sig T3 extends Root {}
sig T4 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 and some T3 and some T4 }
pred grid0067 {
  all x0: T3, x1: T4, x2: T0, x3: T2, x4: T1 |
    (x2 in x4.r and x4 in x0.r and x0 in x1.r and x1 in x3.r and x3 in x2.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r)) and ((some x0.mark) implies (some x1.mark))
}
pred grid0067C {
  all y0: T3, y2: T0, y3: T2, y4: T1, y1: T4 |
    (y2 in y4.r and y4 in y0.r and y0 in y1.r and y1 in y3.r and y3 in y2.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r)) and (not (some y0.mark) or (some y1.mark))
}
assert equivalent { grid0067 iff grid0067C }
check equivalent for 10 but 1..3 steps
