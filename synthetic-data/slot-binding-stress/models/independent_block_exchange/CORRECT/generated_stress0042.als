module slot_stress_0042
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

pred stress0042 {
  all x0: T0, x1: T1, x2: T2, x3: T3, x4: T0, x5: T1, x6: T2, x7: T3, x8: T0, x9: T1, x10: T2, x11: T3, x12: T0, x13: T1, x14: T2, x15: T3, x16: T0, x17: T1, x18: T2, x19: T3, x20: T0, x21: T1, x22: T2, x23: T3, x24: T0, x25: T1, x26: T2, x27: T3, x28: T0, x29: T1, x30: T2, x31: T3 |
    ((x0 in x1.r and x1 in x2.r and x2 in x3.r and x3 in x4.r and x4 in x5.r and x5 in x6.r and x6 in x7.r and x7 in x8.r and x8 in x9.r and x9 in x10.r and x10 in x11.r and x11 in x12.r and x12 in x13.r and x13 in x14.r and x14 in x15.r and x15 in x16.r and x16 in x17.r and x17 in x18.r and x18 in x19.r and x19 in x20.r and x20 in x21.r and x21 in x22.r and x22 in x23.r and x23 in x24.r and x24 in x25.r and x25 in x26.r and x26 in x27.r and x27 in x28.r and x28 in x29.r and x29 in x30.r and x30 in x31.r and x31 in x0.r) and some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r & x8.r & x9.r & x10.r & x11.r & x12.r & x13.r & x14.r & x15.r & x16.r & x17.r & x18.r & x19.r & x20.r & x21.r & x22.r & x23.r & x24.r & x25.r & x26.r & x27.r & x28.r & x29.r & x30.r & x31.r)) and (some x0.mark)
}
pred stress0042C {
  all y027: T3 | all y019: T3 | all y018: T2 | all y012: T0 | all y021: T1 | all y004: T0 | all y014: T2 | all y009: T1 | all y002: T2 | all y013: T1 | all y011: T3 | all y000: T0 | all y005: T1 | all y015: T3 | all y031: T3 | all y022: T2 | all y010: T2 | all y008: T0 | all y020: T0 | all y026: T2 | all y023: T3 | all y030: T2 | all y006: T2 | all y025: T1 | all y029: T1 | all y001: T1 | all y028: T0 | all y017: T1 | all y024: T0 | all y016: T0 | all y003: T3 | all y007: T3 |
    ((y000 in y001.r and y001 in y002.r and y002 in y003.r and y003 in y004.r and y004 in y005.r and y005 in y006.r and y006 in y007.r and y007 in y008.r and y008 in y009.r and y009 in y010.r and y010 in y011.r and y011 in y012.r and y012 in y013.r and y013 in y014.r and y014 in y015.r and y015 in y016.r and y016 in y017.r and y017 in y018.r and y018 in y019.r and y019 in y020.r and y020 in y021.r and y021 in y022.r and y022 in y023.r and y023 in y024.r and y024 in y025.r and y025 in y026.r and y026 in y027.r and y027 in y028.r and y028 in y029.r and y029 in y030.r and y030 in y031.r and y031 in y000.r) and some (y000.r & y001.r & y002.r & y003.r & y004.r & y005.r & y006.r & y007.r & y008.r & y009.r & y010.r & y011.r & y012.r & y013.r & y014.r & y015.r & y016.r & y017.r & y018.r & y019.r & y020.r & y021.r & y022.r & y023.r & y024.r & y025.r & y026.r & y027.r & y028.r & y029.r & y030.r & y031.r)) and (some y000.mark)
}
assert equivalent { stress0042 iff stress0042C }
check equivalent for 12 but 5 Int, 1..3 steps
run { stress0042 } for 12 but 5 Int, 1..3 steps
