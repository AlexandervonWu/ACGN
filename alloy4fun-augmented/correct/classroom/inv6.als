module alloy4fun_augmented_classroom_inv6
open util/integer [] as integer
sig Person {
Tutors: (set Person),
Teaches: (set Class)
}
sig Group {}
sig Class {
Groups: (Person->Group)
}
sig Teacher in Person {}
sig Student in Person {}

pred inv6_oracle[] {
(Teacher in (Teaches.Class))
}

pred inv6_correct_0[] {
(all t: (one Teacher) {
(some c: (one Class) {
((t->c) in Teaches)
})
})
}

pred inv6_correct_1[] {
(all t: (one Teacher) {
(some x: (one Class) {
((t->x) in Teaches)
})
})
}

pred inv6_correct_2[] {
(all t: (one Teacher) {
(some c: (one Class) {
(c in (t.Teaches))
})
})
}

pred inv6_correct_3[] {
(all x: (one Teacher) {
(some c: (one Class) {
((x->c) in Teaches)
})
})
}

pred inv6_correct_4[] {
(all t: (one Teacher) {
(some (t.Teaches))
})
}

pred inv6_correct_5[] {
(all p: (one Teacher) {
(some c: (one Class) {
((p in Teacher) => ((p->c) in Teaches))
})
})
}

pred inv6_correct_6[] {
(all t: (one Teacher) {
((#(t.Teaches)) > 0)
})
}

pred inv6_correct_7[] {
(Teacher in (Class.(~Teaches)))
}

pred inv6_correct_8[] {
(all p: (one Teacher) {
(some c: (one Class) {
((p->c) in Teaches)
})
})
}

pred inv6_correct_9[] {
(all x: (one Teacher) {
(some y: (one Class) {
((x->y) in Teaches)
})
})
}

