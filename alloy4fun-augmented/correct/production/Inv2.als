module alloy4fun_augmented_production_Inv2
open util/integer [] as integer
open util/ordering [Position] as ordering
sig Position {}
sig Product {}
sig Component extends Product {
parts: (set Product),
position: (one Position)
}
sig Resource extends Product {}
sig Robot {
position: (one Position)
}

pred Inv2_oracle[] {
(all c: (one Component) {
(c !in (c.(^parts)))
})
}

pred Inv2_correct_0[] {
(all c: (one Component) {
(no (c & (c.(^parts))))
})
}

pred Inv2_correct_1[] {
(all c: (one Component) {
(c !in (c.(^parts)))
})
}

pred Inv2_correct_2[] {
(no ((^parts) & iden))
}

pred Inv2_correct_3[] {
(all c: (one Component) {
(no ((c.(^parts)) & c))
})
}

pred Inv2_correct_4[] {
(no (iden & (^parts)))
}

pred Inv2_correct_5[] {
(no c: (one Component) {
(c in (c.(^parts)))
})
}

pred Inv2_correct_6[] {
(all c: (one Component) {
(c !in ((c.parts).(*parts)))
})
}

pred Inv2_correct_7[] {
(all c: (one Product) {
(c !in (c.(^parts)))
})
}

pred Inv2_correct_8[] {
(all c: (one Component) {
(c !in ((c.parts).(^parts)))
})
}

