module slot_grid_0071
abstract sig Root { r, mark: set Root }
sig T0 extends Root {}
var sig Live in Root {}
fact Inhabited { some T0 }
pred grid0071 {
  all x0: T0, x1: T0, x2: T0, x3: T0, x4: T0, x5: T0 |
    (x1 in x5.r and x5 in x3.r and x3 in x0.r and x0 in x2.r and x2 in x4.r and x4 in x1.r) and (some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r)) and ((some x0.mark) and ((some x1.mark) and (some x0.mark)))
}
pred grid0071C {
  all y5: T0, y0: T0, y3: T0, y4: T0, y1: T0, y2: T0 |
    (y1 in y5.r and y5 in y3.r and y3 in y0.r and y0 in y2.r and y2 in y4.r and y4 in y1.r) and (some (y0.r & y1.r & y2.r & y3.r & y4.r & y5.r)) and ((some y1.mark) and (some y0.mark))
}
assert equivalent { grid0071 iff grid0071C }
check equivalent for 10 but 1..3 steps
