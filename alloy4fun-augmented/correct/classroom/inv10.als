module alloy4fun_augmented_classroom_inv10
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

pred inv10_oracle[] {
(all c: (one Class),s: (one Student) {
(some (s.(c.Groups)))
})
}

pred inv10_correct_0[] {
(all c: (one Class),s: (one Student) {
(some g: (one Group) {
((c->(s->g)) in Groups)
})
})
}

pred inv10_correct_1[] {
(all x: (one Class),s: (one Student) {
(some g: (one Group) {
((x->(s->g)) in Groups)
})
})
}

pred inv10_correct_2[] {
(all x: (one Class),y: (one Student) {
(some g: (one Group) {
((x->(y->g)) in Groups)
})
})
}

pred inv10_correct_3[] {
(all c: (one Class) {
(all s: (one Student) {
(some g: (one Group) {
((c->(s->g)) in Groups)
})
})
})
}

pred inv10_correct_4[] {
(all c: (one Class),s: (one Student) {
(some g: (one Group) {
((s->g) in (c.Groups))
})
})
}

pred inv10_correct_5[] {
(all s: (one Student),c: (one Class) {
(some g: (one Group) {
((c->(s->g)) in Groups)
})
})
}

pred inv10_correct_6[] {
(all c: (one Class),t: (one Student) {
(some g: (one Group) {
((c->(t->g)) in Groups)
})
})
}

pred inv10_correct_7[] {
(all x: (one Class),y: (one Student) {
(some z: (one Group) {
((x->(y->z)) in Groups)
})
})
}

pred inv10_correct_8[] {
(all x: (one Class),p: (one Student) {
(some g: (one Group) {
((x->(p->g)) in Groups)
})
})
}

pred inv10_correct_9[] {
(all s: (one Student),c: (one Class) {
(some (s.(c.Groups)))
})
}

