module alloy4fun_augmented_train_prop6
open util/integer [] as integer
sig Track {
prox: (set Track),
signal: (lone Signal)
}
sig Junction extends Track {}
sig Entry in Track {}
sig Exit in Track {}
sig Signal {}
var sig Green in Signal {}
sig Train {
var pos: (lone Track)
}

pred prop6_oracle[] {
(all s: (one Signal) {
((always (eventually (s in Green))) && (always (eventually (s !in Green))))
})
}

pred prop6_correct_0[] {
(always (all s: (one Signal) {
(((s in Green) => (eventually (s !in Green))) && ((s !in Green) => (eventually (s in Green))))
}))
}

pred prop6_correct_1[] {
((always (all s: (one (Signal - Green)) {
(eventually (s in Green))
})) && (always (all s: (one Green) {
(eventually (s in (Signal - Green)))
})))
}

