module alloy4fun_augmented_train_prop4
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

pred prop4_oracle[] {
(always (all t: (one Track) {
(lone (pos.t))
}))
}

pred prop4_correct_0[] {
(always (all disj t1,t2: (one Train) {
(no ((t1.pos) & (t2.pos)))
}))
}

pred prop4_correct_1[] {
(always ((pos.(~pos)) in iden))
}

pred prop4_correct_2[] {
(all disj t1,t2: (one Train) {
(always (no ((t1.pos) & (t2.pos))))
})
}

pred prop4_correct_3[] {
(always (all disj t,t2: (one Train) {
((some ((t.pos) + (t2.pos))) => ((t.pos) != (t2.pos)))
}))
}

pred prop4_correct_4[] {
(always (all tk: (one Track) {
(lone (pos.tk))
}))
}

pred prop4_correct_5[] {
(always (all disj t,t2: (one Train) {
((some (t.pos)) => ((t.pos) != (t2.pos)))
}))
}

pred prop4_correct_6[] {
(always (all t: (one Track) {
(lone (t.(~pos)))
}))
}

pred prop4_correct_7[] {
(always (all t: (one Track) {
(lone (pos.t))
}))
}

pred prop4_correct_8[] {
(all t: (one Track) {
(always (lone (t.(~pos))))
})
}

