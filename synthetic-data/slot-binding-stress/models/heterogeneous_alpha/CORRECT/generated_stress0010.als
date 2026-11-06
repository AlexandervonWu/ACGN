module slot_stress_0010
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

pred stress0010 {
  all x0: T0 | some x1: T1 | all x2: T0 | some x3: T1 | all x4: T0 | some x5: T1 | all x6: T0 | some x7: T1 |
    ((x0 in x1.r and x1 in x2.r and x2 in x3.r and x3 in x4.r and x4 in x5.r and x5 in x6.r and x6 in x7.r and x7 in x0.r) and some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r)) and (some x0.mark)
}
pred stress0010C {
  all y000: T0 | some y001: T1 | all y002: T0 | some y003: T1 | all y004: T0 | some y005: T1 | all y006: T0 | some y007: T1 |
    ((y000 in y001.r and y001 in y002.r and y002 in y003.r and y003 in y004.r and y004 in y005.r and y005 in y006.r and y006 in y007.r and y007 in y000.r) and some (y000.r & y001.r & y002.r & y003.r & y004.r & y005.r & y006.r & y007.r)) and (some y000.mark)
}
assert equivalent { stress0010 iff stress0010C }
check equivalent for 12 but 5 Int, 1..3 steps
run { stress0010 } for 12 but 5 Int, 1..3 steps
