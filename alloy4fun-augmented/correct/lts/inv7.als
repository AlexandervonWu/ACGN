module alloy4fun_augmented_lts_inv7
open util/integer [] as integer
sig State {
trans: (Event->State)
}
sig Init in State {}
sig Event {}

pred inv7_oracle[] {
(let tr = ({ s1,s2: (one State) {
(some e: (one Event) {
((s1->(e->s2)) in trans)
})
} }) {
(all s: (one (Init.(^tr))) {
(some i: (one Init) {
(i in (s.(^tr)))
})
})
})
}

