module alloy4fun_augmented_train_prop2
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

pred prop2_oracle[] {
(all s: (one Signal) {
(eventually (s in Green))
})
}

pred prop2_correct_0[] {
(all s: (one Signal) {
(eventually (s in Green))
})
}

pred prop2_correct_1[] {
(eventually (all s: (one Signal) {
(eventually (s in Green))
}))
}

pred prop2_correct_2[] {
(all s: (one (Signal - Green)) {
(eventually (s in Green))
})
}

pred prop2_correct_3[] {
(all t: (one Track) {
(eventually ((t.signal) in Green))
})
}

