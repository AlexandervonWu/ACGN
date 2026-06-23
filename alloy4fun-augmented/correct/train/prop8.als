module alloy4fun_augmented_train_prop8
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

pred prop8_oracle[] {
(all t: (one Train),p: (one Track) {
(always ((((t.pos) = p) && ((p.signal) !in Green)) => (((p.signal) in Green) releases ((t.pos) = p))))
})
}

pred prop8_correct_0[] {
(always (all t: (one Train) {
(((some ((t.pos).signal)) && (((t.pos).signal) in (Signal - Green))) => ((t.(pos')) = (t.pos)))
}))
}

pred prop8_correct_1[] {
(always (all t: (one Train) {
(((some ((t.pos).signal)) && (((t.pos).signal) !in Green)) => ((t.(pos')) = (t.pos)))
}))
}

