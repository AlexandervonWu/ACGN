module alloy4fun_augmented_train_prop14
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

pred prop14_oracle[] {
(all s: (one Signal),t: (one Train) {
(always (((s in Green) && ((t.pos) = (signal.s)) && ((t.(pos')) != (signal.s))) => (after (s !in Green))))
})
}

