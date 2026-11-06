module slot_stress_1023
open util/integer as ints
open util/ordering[T7] as ord
abstract sig Root {
  r, mark: set Root,
  tri: Root -> Root,
  var changing: set Root
}
sig T0 extends Root { owned: set Root }
sig T1 extends Root { owned: set Root }
sig T2, T3, T4, T5, T6, T7 extends Root {}
sig Leaf, Peer extends T0 {}
sig Overlap in T0 + T1 {}
var sig Live in Root {}
fact Inhabited { some T0 and some T1 and some T2 and some T3
  and some T4 and some T5 and some T6 and some T7 }
fun forward[u: Root]: set Root { u.r }
fun links[u: Root, v: Root]: set Root { u.(tri.v) }

pred stress1023 {
  all x0: T0, x1: T1, x2: T0, x3: T1 |
    ((x0 in x1.r and x1 in x2.r and x2 in x3.r and x3 in x0.r) and some (x0.r & x1.r & x2.r & x3.r)) and (all a:T0 | some b:T1 | a->b in mark)
}
pred stress1023C {
  all y000: T0, y001: T1, y002: T0, y003: T1 |
    ((y000 in y001.r and y001 in y002.r and y002 in y003.r and y003 in y000.r) and some (y000.r & y001.r & y002.r & y003.r)) and (some b:T1 | all a:T0 | a->b in mark)
}
assert equivalent { stress1023 iff stress1023C }
check equivalent for 10 but exactly 2 T0, exactly 2 T1, exactly 1 T2, exactly 1 T3, exactly 1 T4, exactly 1 T5, exactly 1 T6, exactly 1 T7, 5 Int, 1..3 steps
run { stress1023 } for 10 but exactly 2 T0, exactly 2 T1, exactly 1 T2, exactly 1 T3, exactly 1 T4, exactly 1 T5, exactly 1 T6, exactly 1 T7, 5 Int, 1..3 steps
