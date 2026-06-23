module alloy4fun_augmented_train_prop15
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

pred prop15_oracle[] {
(all t: (one Train),p: (one Track) {
(!(eventually (always ((t.pos) = p))))
})
}

pred prop15_correct_0[] {
(always (eventually (all t: (one Train) {
((((no (t.pos)) => (eventually (some (t.pos)))) && (some (t.pos))) => (eventually ((t.pos) != (t.(pos')))))
})))
}

pred prop15_correct_1[] {
(always (all t: (one (pos.Track)) {
(eventually (((t.pos)') != (t.pos)))
}))
}

pred prop15_correct_2[] {
(always (all t: (one Train) {
((some (t.pos)) => (eventually ((t.pos) != (t.(pos')))))
}))
}

