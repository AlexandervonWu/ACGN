module alloy4fun_augmented_lts_inv2
open util/integer [] as integer
sig State {
trans: (Event->State)
}
sig Init in State {}
sig Event {}

pred inv2_oracle[] {
(one Init)
}

pred inv2_correct_0[] {
(always (one Init))
}

pred inv2_correct_1[] {
(one s: (one State) {
(s in Init)
})
}

