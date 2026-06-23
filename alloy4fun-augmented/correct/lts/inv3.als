module alloy4fun_augmented_lts_inv3
open util/integer [] as integer
sig State {
trans: (Event->State)
}
sig Init in State {}
sig Event {}

pred inv3_oracle[] {
(all s: (one State),e: (one Event) {
(lone (e.(s.trans)))
})
}

pred inv3_correct_0[] {
(all s: (one State),e: (one Event) {
(lone (e.(s.trans)))
})
}

pred inv3_correct_1[] {
(all s: (one State) {
(all e: (one Event) {
(lone (e.(s.trans)))
})
})
}

pred inv3_correct_2[] {
(all s: (one State),e: (one Event) {
(lone ((e->State) & (s.trans)))
})
}

pred inv3_correct_3[] {
(all s: (one State),e: (one Event) {
(lone ((~(s.trans)).e))
})
}

pred inv3_correct_4[] {
(all s: (one State) {
(((~(s.trans)).(s.trans)) in iden)
})
}

pred inv3_correct_5[] {
(all e: (one Event),s: (one State) {
(lone (e <: (s.trans)))
})
}

pred inv3_correct_6[] {
(all s: (one State),e: (one Event) {
(lone (e <: (s.trans)))
})
}

pred inv3_correct_7[] {
(all s,s1,s2: (one State),e: (one Event) {
((((s->(e->s1)) in trans) && ((s->(e->s2)) in trans)) => (s1 = s2))
})
}

pred inv3_correct_8[] {
(all x: (one State),y: (one Event) {
(lone (y.(x.trans)))
})
}

pred inv3_correct_9[] {
(all e: (one Event),s: (one State) {
(lone (e.(s.trans)))
})
}

pred inv3_correct_10[] {
(all x,z,v: (one State),y: (one Event) {
((((x->(y->z)) in trans) && ((x->(y->v)) in trans)) => (z = v))
})
}

pred inv3_correct_11[] {
(trans in (State->(Event->lone State)))
}

