module alloy4fun_augmented_train_prop3
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

pred prop3_oracle[] {
(always ((pos') = pos))
}

pred prop3_correct_0[] {
(all t: (one Train) {
(always ((t.(pos')) = (t.pos)))
})
}

pred prop3_correct_1[] {
(always (pos = (pos')))
}

pred prop3_correct_2[] {
(all t: (one Train) {
(always ((t.pos) = (t.(pos'))))
})
}

pred prop3_correct_3[] {
(always (all t: (one Train) {
((t.(pos')) = (t.pos))
}))
}

pred prop3_correct_4[] {
(always (all t: (one Train),tk: (one Track) {
((((t->tk) in pos) => (always ((t->tk) in pos))) && (((t->tk) !in pos) => (always ((t->tk) !in pos))))
}))
}

pred prop3_correct_5[] {
(always (all t: (one Train) {
(((t.pos)') = (t.pos))
}))
}

pred prop3_correct_6[] {
(all t: (one Train),tk: (one Track) {
((((t->tk) in pos) => (always ((t->tk) in pos))) && (((t->tk) !in pos) => (always ((t->tk) !in pos))))
})
}

pred prop3_correct_7[] {
(always (all t: (one Train) {
((t.pos) = (t.(pos')))
}))
}

pred prop3_correct_8[] {
(always (all t: (one Train) {
(always ((t.(pos')) = (t.pos)))
}))
}

