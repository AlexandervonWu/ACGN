module alloy4fun_augmented_train_prop10
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

pred prop10_oracle[] {
(all j: (one Junction) {
(always (lone (((prox.j).signal) & Green)))
})
}

pred prop10_correct_0[] {
((always (all j: (one Junction) {
(lone (((prox.j).signal) & Green))
})) && (always (lone (((prox.Junction).signal) & Green))))
}

pred prop10_correct_1[] {
(always (lone (((prox.Junction).signal) & Green)))
}

pred prop10_correct_2[] {
(always (all j: (one Junction) {
(lone (((prox.j).signal) & Green))
}))
}

pred prop10_correct_3[] {
(always (all j: (one Junction) {
(lone (((prox.j).signal) :> Green))
}))
}

pred prop10_correct_4[] {
(always (all j: (one Junction) {
(lone (((prox.Junction).signal) & Green))
}))
}

