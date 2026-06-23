module alloy4fun_augmented_lts_inv5
open util/integer [] as integer
sig State {
trans: (Event->State)
}
sig Init in State {}
sig Event {}

pred inv5_oracle[] {
(all s: (one State),s1: (one State) {
(((s.trans).State) = ((s1.trans).State))
})
}

pred inv5_correct_0[] {
(all s: (one State) {
((s.(trans.State)) = (State.(trans.State)))
})
}

pred inv5_correct_1[] {
(all s1,s2: (one State) {
(((s1.trans).State) = ((s2.trans).State))
})
}

pred inv5_correct_2[] {
(all s1,s2: (one State),e: (one Event) {
((some (e.(s1.trans))) => (some (e.(s2.trans))))
})
}

pred inv5_correct_3[] {
(all disj s,ss: (one State) {
(((s.trans).State) = ((ss.trans).State))
})
}

pred inv5_correct_4[] {
(all disj s,t: (one State) {
(((s.trans).State) = ((t.trans).State))
})
}

pred inv5_correct_5[] {
(all disj s,s1: (one State) {
(((s.trans).State) = ((s1.trans).State))
})
}

pred inv5_correct_6[] {
(all s,r: (one State) {
(((r.trans).State) = ((s.trans).State))
})
}

pred inv5_correct_7[] {
(all s: (one State),s1: (one State) {
(((s.trans).State) = ((s1.trans).State))
})
}

pred inv5_correct_8[] {
(all s: (one State) {
(((s.trans).State) = ((State.trans).State))
})
}

pred inv5_correct_9[] {
(all disj s1,s2: (one State) {
((no (((s1.trans).State) - ((s2.trans).State))) && (no (((s2.trans).State) - ((s1.trans).State))))
})
}

pred inv5_correct_10[] {
(all s,s1: (one State) {
(no (((s.trans).State) - ((s1.trans).State)))
})
}

pred inv5_correct_11[] {
(all s,r: (one State) {
(((s.trans).State) = ((r.trans).State))
})
}

pred inv5_correct_12[] {
(all disj s1,s2: (one State) {
((State.(~(s1.trans))) = (State.(~(s2.trans))))
})
}

pred inv5_correct_13[] {
(all s1,s2: (one State),e: (one Event) {
(((s1.trans).State) = ((s2.trans).State))
})
}

