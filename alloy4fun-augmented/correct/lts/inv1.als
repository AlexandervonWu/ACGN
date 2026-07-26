module alloy4fun_augmented_lts_inv1
open util/integer [] as integer
sig State {
trans: (Event->State)
}
sig Init in State {}
sig Event {}

pred inv1_oracle[] {
(all s: (one State) {
(some (s.trans))
})
}

pred inv1_correct_0[] {
(((trans.State).Event) = State)
}

pred inv1_correct_1[] {
(no s: (one State) {
(no (s.trans))
})
}

pred inv1_correct_2[] {
(State = ((trans.State).Event))
}

pred inv1_correct_3[] {
(all s: (one State) {
(some ((s.trans) :> State))
})
}

pred inv1_correct_4[] {
(all x: (one State) {
(some (x.trans))
})
}

pred inv1_correct_5[] {
(always (all s: (one State) {
(some (s.trans))
}))
}

pred inv1_correct_6[] {
(all s: (one State) {
(some (Event.(s.trans)))
})
}

pred inv1_correct_7[] {
((State.iden) in ((trans.State).Event))
}

pred inv1_correct_8[] {
(State in ((trans.State).Event))
}

