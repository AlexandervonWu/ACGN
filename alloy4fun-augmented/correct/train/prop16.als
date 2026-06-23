module alloy4fun_augmented_train_prop16
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

pred prop16_oracle[] {
(all t: (one Train) {
(always ((some ((t.pos) & Exit)) => ((some (t.pos)) since (some ((t.pos) & Entry)))))
})
}

pred prop16_correct_0[] {
(always (all t: (one Train) {
((one ((t.pos) :> Exit)) => ((some (t.pos)) since (one ((t.pos) :> Entry))))
}))
}

