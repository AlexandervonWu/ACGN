module alloy4fun_augmented_classroom_rl_inv7
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

pred inv7_oracle[] {
(Class in (Teacher.Teaches))
}

pred inv7_correct_0[] {
(all c: (one Class) {
(some t: (one Teacher) {
((t->c) in Teaches)
})
})
}

pred inv7_correct_1[] {
((Teacher.Teaches) = Class)
}

pred inv7_correct_2[] {
(all c: (one Class) {
(some ((c.(~Teaches)) & Teacher))
})
}

pred inv7_correct_3[] {
(all y: (one Class) {
(some x: (one Teacher) {
((x->y) in Teaches)
})
})
}

pred inv7_correct_4[] {
(all c: (one Class) {
(some t: (one Teacher) {
(c in (t.Teaches))
})
})
}

pred inv7_correct_5[] {
(all c: (one Class) {
(some t: (one Teacher) {
(t in (Teaches.c))
})
})
}

pred inv7_correct_6[] {
(all c: (one Class) {
(c in (Teacher.Teaches))
})
}

pred inv7_correct_7[] {
((all c: (one Class) {
(some t: (one Teacher) {
(t in (c.(~Teaches)))
})
}) && (Class in (Teacher.Teaches)))
}

pred inv7_correct_8[] {
(all c: (one Class) {
(some t: (one Teacher) {
(t in (c.(~Teaches)))
})
})
}

pred inv7_correct_9[] {
(all x: (one Class) {
(some t: (one Teacher) {
((t->x) in Teaches)
})
})
}

pred inv7_correct_10[] {
(Class in (Teacher.Teaches))
}

pred inv7_correct_11[] {
(all c: (one Class) {
(some x: (one Teacher) {
((x->c) in Teaches)
})
})
}

pred inv7_correct_12[] {
(all x: (one Class) {
(some y: (one Teacher) {
((y->x) in Teaches)
})
})
}

