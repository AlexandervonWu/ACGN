module alloy4fun_augmented_classroom_inv12
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

pred inv12_oracle[] {
(all t: (one Teacher) {
(some ((t.Teaches).Groups))
})
}

pred inv12_correct_0[] {
(all t: (one Teacher) {
(some c: (one Class),p: (one Person),g: (one Group) {
(((c->(p->g)) in Groups) && ((t->c) in Teaches))
})
})
}

pred inv12_correct_1[] {
(all t: (one Teacher) {
(some c: (one (t.Teaches)) {
(some (c.Groups))
})
})
}

pred inv12_correct_2[] {
(all t: (one Teacher) {
(some c: (one Class),g: (one Group),p: (one Person) {
(((c->(p->g)) in Groups) && ((t->c) in Teaches))
})
})
}

pred inv12_correct_3[] {
(all t: (one Teacher) {
(some c: (one Class) {
(((t->c) in Teaches) && (some g: (one Group),s: (one Person) {
((c->(s->g)) in Groups)
}))
})
})
}

pred inv12_correct_4[] {
(all t: (one Teacher) {
(some c: (one Class) {
(((t->c) in Teaches) && (some p: (one Person),g: (one Group) {
((c->(p->g)) in Groups)
}))
})
})
}

pred inv12_correct_5[] {
(all x: (one Teacher) {
(some y: (one Class),z: (one Group),v: (one Person) {
(((x->y) in Teaches) && ((y->(v->z)) in Groups))
})
})
}

pred inv12_correct_6[] {
(all t: (one Teacher) {
(some p: (one Person),c: (one Class),g: (one Group) {
(((t->c) in Teaches) && ((c->(p->g)) in Groups))
})
})
}

pred inv12_correct_7[] {
(all t: (one Teacher) {
(some g: (one Group),c: (one Class),p: (one Person) {
(((t->c) in Teaches) && ((c->(p->g)) in Groups))
})
})
}

pred inv12_correct_8[] {
(all t: (one Teacher) {
(some c: (one Class),p: (one Person),g: (one Group) {
(((t->c) in Teaches) && ((c->(p->g)) in Groups))
})
})
}

pred inv12_correct_9[] {
(all t: (one Teacher) {
(some c: (one Class) {
(((t->c) in Teaches) && (some g: (one Group),p: (one Person) {
((c->(p->g)) in Groups)
}))
})
})
}

pred inv12_correct_10[] {
(all t: (one Teacher) {
(some c: (one Class),g: (one Group),p: (one Person) {
(((t->c) in Teaches) && ((c->(p->g)) in Groups))
})
})
}

pred inv12_correct_11[] {
(all t: (one Teacher) {
(some c: (one Class) {
(((t->c) in Teaches) && (some g: (one Group) {
(some p: (one Person) {
((c->(p->g)) in Groups)
})
}))
})
})
}

