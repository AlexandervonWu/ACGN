module alloy4fun_augmented_train_prop13
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

pred prop13_oracle[] {
(all t: (one Train) {
(always (((no (t.pos)) && (once (some (t.pos)))) => (always (no (t.pos)))))
})
}

pred prop13_correct_0[] {
(always (all t: (one Train) {
(((once (some (t.pos))) && (no (t.pos))) => (always (no (t.pos))))
}))
}

pred prop13_correct_1[] {
(always (all t: (one Train) {
(((before (once (some (t.pos)))) && (no (t.pos))) => (always (no (t.pos))))
}))
}

pred prop13_correct_2[] {
(always (all t: (one Train) {
(((one (t.pos)) && (no (t.(pos')))) => (always (no (t.(pos')))))
}))
}

