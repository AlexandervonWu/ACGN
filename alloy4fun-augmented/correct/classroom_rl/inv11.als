module alloy4fun_augmented_classroom_rl_inv11
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

pred inv11_oracle[] {
(all c: (one Class) {
((some (c.Groups)) => (some (Teacher & (Teaches.c))))
})
}

pred inv11_correct_0[] {
(all c: (one Class) {
((some p: (one Person),g: (one Group) {
((c->(p->g)) in Groups)
}) => (some t: (one Teacher) {
((t->c) in Teaches)
}))
})
}

pred inv11_correct_1[] {
(all c: (one Class),g: (one Group),p: (one Person) {
(((c->(p->g)) in Groups) => (some t: (one Teacher) {
((t->c) in Teaches)
}))
})
}

pred inv11_correct_2[] {
(all c: (one Class) {
((some (c.Groups)) => (some t: (one Teacher) {
((t->c) in Teaches)
}))
})
}

pred inv11_correct_3[] {
(all c: (one Class),p: (one Person),g: (one Group) {
(((c->(p->g)) in Groups) => (some t: (one Teacher) {
((t->c) in Teaches)
}))
})
}

pred inv11_correct_4[] {
(all x: (one Class) {
((some y: (one Person),z: (one Group) {
((x->(y->z)) in Groups)
}) => (some v: (one Teacher) {
((v->x) in Teaches)
}))
})
}

pred inv11_correct_5[] {
(all c: (one Class),g: (one Group) {
((some ((c.Groups).g)) => (some t: (one Teacher) {
((t->c) in Teaches)
}))
})
}

pred inv11_correct_6[] {
(all c: (one Class) {
((some g: (one Group) {
(some p: (one Person) {
((c->(p->g)) in Groups)
})
}) => (some t: (one Teacher) {
((t->c) in Teaches)
}))
})
}

pred inv11_correct_7[] {
(all c: (one Class) {
((some (c.Groups)) => (some (Teacher & (c.(~Teaches)))))
})
}

pred inv11_correct_8[] {
(all c: (one Class) {
((some g: (one Group),p: (one Person) {
((c->(p->g)) in Groups)
}) => (some t: (one Teacher) {
((t->c) in Teaches)
}))
})
}

pred inv11_correct_9[] {
(all x: (one Class) {
((some p: (one Person),g: (one Group) {
((x->(p->g)) in Groups)
}) => (some t: (one Teacher) {
((t->x) in Teaches)
}))
})
}

pred inv11_correct_10[] {
(all c: (one Class) {
((some s: (one Person),g: (one Group) {
((c->(s->g)) in Groups)
}) => (some t: (one Teacher) {
((t->c) in Teaches)
}))
})
}

pred inv11_correct_11[] {
(all c: (one Class) {
((all t: (one Teacher) {
((t->c) !in Teaches)
}) => (all p: (one Person),g: (one Group) {
((c->(p->g)) !in Groups)
}))
})
}

pred inv11_correct_12[] {
(all c: (one Class),s: (one Person),g: (one Group) {
(some t: (one Person) {
(((c->(s->g)) in Groups) => (((t->c) in Teaches) && (t in Teacher)))
})
})
}

pred inv11_correct_13[] {
(all c: (one Class) {
(all g: (one Group),p: (one Person) {
(((c->(p->g)) in Groups) => (some t: (one Teacher) {
((t->c) in Teaches)
}))
})
})
}

pred inv11_correct_14[] {
(all c: (one Class) {
((some (Person.(c.Groups))) => (some t: (one Teacher) {
((t->c) in Teaches)
}))
})
}

pred inv11_correct_15[] {
(all c: (one Class) {
((some g: (one Group),s: (one Person) {
((c->(s->g)) in Groups)
}) => (some t: (one Teacher) {
((t->c) in Teaches)
}))
})
}

pred inv11_correct_16[] {
(all c: (one Class) {
((some ((c.Groups).Group)) => (some t: (one Teacher) {
((t->c) in Teaches)
}))
})
}

