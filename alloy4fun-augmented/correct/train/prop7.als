module alloy4fun_augmented_train_prop7
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

pred prop7_oracle[] {
(all t: (one Train) {
(always ((some (t.pos)) => (eventually (no (t.pos)))))
})
}

pred prop7_correct_0[] {
(always (all t: (one (pos.Track)) {
(eventually (no (t.pos)))
}))
}

pred prop7_correct_1[] {
(always (all t: (one Train) {
((some (t.pos)) => (eventually (no (t.pos))))
}))
}

pred prop7_correct_2[] {
(always (all t: (one Train) {
((some ((t.pos) :> Track)) => (eventually (no ((t.pos) :> Track))))
}))
}

