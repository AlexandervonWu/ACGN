module alloy4fun_augmented_train_prop9
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

pred prop9_oracle[] {
(all t: (one Train) {
((no (t.pos)) until (some ((t.pos) & Entry)))
})
}

