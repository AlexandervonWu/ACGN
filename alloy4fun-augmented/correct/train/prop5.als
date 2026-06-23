module alloy4fun_augmented_train_prop5
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

pred prop5_oracle[] {
(all t: (one Train) {
(always ((some (t.pos)) => (((t.(pos')) = (t.pos)) || (((t.pos) in Exit) => (no (t.(pos'))) else ((some (t.(pos'))) && ((t.(pos')) in ((t.pos).prox)))))))
})
}

