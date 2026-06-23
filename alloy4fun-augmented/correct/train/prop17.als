module alloy4fun_augmented_train_prop17
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

pred prop17_oracle[] {
(all t: (one Train) {
(always (((some (t.pos)) && (historically (no ((Train - t).pos)))) => ((no ((Train.pos) & Exit)) until (some ((t.pos) & Exit)))))
})
}

