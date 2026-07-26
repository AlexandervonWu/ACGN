module alloy4fun_augmented_production_Inv1
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

pred Inv1_oracle[] {
(all c: (one Component) {
(some (c.parts))
})
}

pred Inv1_correct_0[] {
(all c: (one Component) {
((#(c.parts)) >= 1)
})
}

pred Inv1_correct_1[] {
(Component in (parts.Product))
}

pred Inv1_correct_2[] {
((iden & (Component->Component)) in (parts.(~parts)))
}

pred Inv1_correct_3[] {
((iden & (Component->Product)) in (parts.(~parts)))
}

pred Inv1_correct_4[] {
(parts in (Component->some Product))
}

