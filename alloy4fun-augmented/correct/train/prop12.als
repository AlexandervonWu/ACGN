module alloy4fun_augmented_train_prop12
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

pred prop12_oracle[] {
(all t: (one Train) {
(always ((some (t.pos)) => (some e: (one (((*prox).(t.pos)) & Entry)) {
(all x: (one (((*prox).(t.pos)) & (e.(*prox)))) {
(once ((t.pos) = x))
})
})))
})
}

