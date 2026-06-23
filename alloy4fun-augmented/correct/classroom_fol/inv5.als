module alloy4fun_augmented_classroom_fol_inv5
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

pred inv5_oracle[] {
(some (Teacher.Teaches))
}

pred inv5_correct_0[] {
(some c: (one Class) {
(some t: (one Teacher) {
((t->c) in Teaches)
})
})
}

pred inv5_correct_1[] {
(some x: (one Class),t: (one Teacher) {
((t->x) in Teaches)
})
}

pred inv5_correct_2[] {
(some t: (one Teacher),c: (one Class) {
((t->c) in Teaches)
})
}

pred inv5_correct_3[] {
(some c: (one Class),t: (one Teacher) {
((t->c) in Teaches)
})
}

pred inv5_correct_4[] {
(some t: (one Teacher) {
(some c: (one Class) {
((t->c) in Teaches)
})
})
}

pred inv5_correct_5[] {
(some c: (one Class) {
(some x: (one Teacher) {
((x->c) in Teaches)
})
})
}

pred inv5_correct_6[] {
(some c: (one Class),t: (one Teacher) {
(c in (t.Teaches))
})
}

pred inv5_correct_7[] {
(some c: (one Class),p: (one Teacher) {
((p->c) in Teaches)
})
}

pred inv5_correct_8[] {
(some c: (one Class),p: (one Person) {
(((p->c) in Teaches) && (p in Teacher))
})
}

pred inv5_correct_9[] {
(some p: (one Teacher),c: (one Class) {
((p->c) in Teaches)
})
}

pred inv5_correct_10[] {
(some x: (one Teacher),y: (one Class) {
((x->y) in Teaches)
})
}

pred inv5_correct_11[] {
(some p: (one Person),c: (one Class) {
((p in Teacher) && ((p->c) in Teaches))
})
}

pred inv5_correct_12[] {
(some c: (one Class) {
(some t: (one Teacher) {
(c in (t.Teaches))
})
})
}

pred inv5_correct_13[] {
(some (Teacher.Teaches))
}

pred inv5_correct_14[] {
(some c: (one Class) {
(c in (Teacher.Teaches))
})
}

pred inv5_correct_15[] {
(some x: (one Teacher) {
(some c: (one Class) {
((x->c) in Teaches)
})
})
}

