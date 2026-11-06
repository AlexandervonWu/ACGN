module slot_stress_0023
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

pred stress0023 {
  all disj x0, x8, x16, x24, x32, x40, x48, x56: T0, disj x1, x9, x17, x25, x33, x41, x49, x57: T1, disj x2, x10, x18, x26, x34, x42, x50, x58: T2, disj x3, x11, x19, x27, x35, x43, x51, x59: T3, disj x4, x12, x20, x28, x36, x44, x52, x60: T4, disj x5, x13, x21, x29, x37, x45, x53, x61: T5, disj x6, x14, x22, x30, x38, x46, x54, x62: T6, disj x7, x15, x23, x31, x39, x47, x55, x63: T7 |
    ((x0 in x1.r and x1 in x2.r and x2 in x3.r and x3 in x4.r and x4 in x5.r and x5 in x6.r and x6 in x7.r and x7 in x8.r and x8 in x9.r and x9 in x10.r and x10 in x11.r and x11 in x12.r and x12 in x13.r and x13 in x14.r and x14 in x15.r and x15 in x16.r and x16 in x17.r and x17 in x18.r and x18 in x19.r and x19 in x20.r and x20 in x21.r and x21 in x22.r and x22 in x23.r and x23 in x24.r and x24 in x25.r and x25 in x26.r and x26 in x27.r and x27 in x28.r and x28 in x29.r and x29 in x30.r and x30 in x31.r and x31 in x32.r and x32 in x33.r and x33 in x34.r and x34 in x35.r and x35 in x36.r and x36 in x37.r and x37 in x38.r and x38 in x39.r and x39 in x40.r and x40 in x41.r and x41 in x42.r and x42 in x43.r and x43 in x44.r and x44 in x45.r and x45 in x46.r and x46 in x47.r and x47 in x48.r and x48 in x49.r and x49 in x50.r and x50 in x51.r and x51 in x52.r and x52 in x53.r and x53 in x54.r and x54 in x55.r and x55 in x56.r and x56 in x57.r and x57 in x58.r and x58 in x59.r and x59 in x60.r and x60 in x61.r and x61 in x62.r and x62 in x63.r and x63 in x0.r) and some (x0.r & x1.r & x2.r & x3.r & x4.r & x5.r & x6.r & x7.r & x8.r & x9.r & x10.r & x11.r & x12.r & x13.r & x14.r & x15.r & x16.r & x17.r & x18.r & x19.r & x20.r & x21.r & x22.r & x23.r & x24.r & x25.r & x26.r & x27.r & x28.r & x29.r & x30.r & x31.r & x32.r & x33.r & x34.r & x35.r & x36.r & x37.r & x38.r & x39.r & x40.r & x41.r & x42.r & x43.r & x44.r & x45.r & x46.r & x47.r & x48.r & x49.r & x50.r & x51.r & x52.r & x53.r & x54.r & x55.r & x56.r & x57.r & x58.r & x59.r & x60.r & x61.r & x62.r & x63.r)) and (some x0.mark)
}
pred stress0023C {
  all disj y056, y008, y016, y000, y048, y032, y024, y040: T0, disj y057, y017, y041, y033, y009, y001, y049, y025: T1, disj y050, y034, y026, y058, y042, y010, y018, y002: T2, disj y011, y051, y035, y003, y059, y019, y043, y027: T3, disj y052, y004, y020, y060, y028, y044, y036, y012: T4, disj y029, y021, y037, y061, y013, y053, y045, y005: T5, disj y014, y006, y022, y038, y062, y030, y046, y054: T6, disj y047, y055, y007, y023, y039, y031, y015, y063: T7 |
    ((y000 in y001.r and y001 in y002.r and y002 in y003.r and y003 in y004.r and y004 in y005.r and y005 in y006.r and y006 in y007.r and y007 in y008.r and y008 in y009.r and y009 in y010.r and y010 in y011.r and y011 in y012.r and y012 in y013.r and y013 in y014.r and y014 in y015.r and y015 in y016.r and y016 in y017.r and y017 in y018.r and y018 in y019.r and y019 in y020.r and y020 in y021.r and y021 in y022.r and y022 in y023.r and y023 in y024.r and y024 in y025.r and y025 in y026.r and y026 in y027.r and y027 in y028.r and y028 in y029.r and y029 in y030.r and y030 in y031.r and y031 in y032.r and y032 in y033.r and y033 in y034.r and y034 in y035.r and y035 in y036.r and y036 in y037.r and y037 in y038.r and y038 in y039.r and y039 in y040.r and y040 in y041.r and y041 in y042.r and y042 in y043.r and y043 in y044.r and y044 in y045.r and y045 in y046.r and y046 in y047.r and y047 in y048.r and y048 in y049.r and y049 in y050.r and y050 in y051.r and y051 in y052.r and y052 in y053.r and y053 in y054.r and y054 in y055.r and y055 in y056.r and y056 in y057.r and y057 in y058.r and y058 in y059.r and y059 in y060.r and y060 in y061.r and y061 in y062.r and y062 in y063.r and y063 in y000.r) and some (y000.r & y001.r & y002.r & y003.r & y004.r & y005.r & y006.r & y007.r & y008.r & y009.r & y010.r & y011.r & y012.r & y013.r & y014.r & y015.r & y016.r & y017.r & y018.r & y019.r & y020.r & y021.r & y022.r & y023.r & y024.r & y025.r & y026.r & y027.r & y028.r & y029.r & y030.r & y031.r & y032.r & y033.r & y034.r & y035.r & y036.r & y037.r & y038.r & y039.r & y040.r & y041.r & y042.r & y043.r & y044.r & y045.r & y046.r & y047.r & y048.r & y049.r & y050.r & y051.r & y052.r & y053.r & y054.r & y055.r & y056.r & y057.r & y058.r & y059.r & y060.r & y061.r & y062.r & y063.r)) and (some y000.mark)
}
assert equivalent { stress0023 iff stress0023C }
check equivalent for 12 but 5 Int, 1..3 steps
run { stress0023 } for 12 but 5 Int, 1..3 steps
