module alloy4fun_augmented_train_prop1
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

pred prop1_oracle[] {
(no Green)
}

pred prop1_correct_0[] {
(no Green)
}

pred prop1_correct_1[] {
((some s: (one Signal) {
(s in Green)
}) since (historically (all s: (one Signal) {
(s !in Green)
})))
}

pred prop1_correct_2[] {
(no s: (one Green) {
(s in Signal)
})
}

pred prop1_correct_3[] {
(all s: (one Signal) {
(s !in Green)
})
}

pred prop1_correct_4[] {
(historically (no Green))
}

pred prop1_correct_5[] {
(no (Signal & Green))
}

pred prop1_correct_6[] {
(all s: (one Signal) {
(no Green)
})
}

