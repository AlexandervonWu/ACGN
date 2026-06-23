module alloy4fun_augmented_train_prop11
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

pred prop11_oracle[] {
(all t: (one Train) {
(always ((some (t.pos)) => (once (some ((t.pos) & Entry)))))
})
}

pred prop11_correct_0[] {
(always (all t: (one Train) {
((some (t.pos)) => (once (some ((t.pos) :> Entry))))
}))
}

pred prop11_correct_1[] {
(always (all t: (one Train) {
((some (t.pos)) => (once ((some (t.pos)) && ((t.pos) in Entry))))
}))
}

