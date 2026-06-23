module alloy4fun_augmented_classroom_fol_inv8
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

pred inv8_oracle[] {
(all t: (one Teacher) {
(lone (t.Teaches))
})
}

pred inv8_correct_0[] {
(all x: (one Teacher),y,z: (one Class) {
((((x->y) in Teaches) && ((x->z) in Teaches)) => (y = z))
})
}

pred inv8_correct_1[] {
(all t: (one Teacher) {
((#(t.Teaches)) < 2)
})
}

pred inv8_correct_2[] {
(all t: (one Teacher) {
(lone c: (one Class) {
((t->c) in Teaches)
})
})
}

pred inv8_correct_3[] {
(all t: (one Teacher),c,c1: (one Class) {
((((t->c) in Teaches) && ((t->c1) in Teaches)) => (c = c1))
})
}

pred inv8_correct_4[] {
(all t: (one Teacher),c1,c2: (one Class) {
((((t->c1) in Teaches) && ((t->c2) in Teaches)) => (c1 = c2))
})
}

pred inv8_correct_5[] {
(all c1: (one Class),c2: (one Class),t: (one Teacher) {
((((t->c1) in Teaches) && ((t->c2) in Teaches)) => (c1 = c2))
})
}

pred inv8_correct_6[] {
(all x,y: (one Class),t: (one Teacher) {
((((t->x) in Teaches) && ((t->y) in Teaches)) => (x = y))
})
}

pred inv8_correct_7[] {
(all t: (one Teacher) {
(all c1,c2: (one Class) {
((((t->c1) in Teaches) && ((t->c2) in Teaches)) => (c1 = c2))
})
})
}

pred inv8_correct_8[] {
(all t: (one Teacher) {
(all c,u: (one Class) {
((((t->c) in Teaches) && ((t->u) in Teaches)) => (c = u))
})
})
}

pred inv8_correct_9[] {
(all t: (one Teacher) {
(lone (t.Teaches))
})
}

pred inv8_correct_10[] {
(all t: (one Teacher),c,d: (one Class) {
((((t->c) in Teaches) && ((t->d) in Teaches)) => (c = d))
})
}

pred inv8_correct_11[] {
((all t: (one Teacher) {
(lone (t.Teaches))
}) && (((~(Teacher <: Teaches)).(Teacher <: Teaches)) in iden))
}

pred inv8_correct_12[] {
(all t: (one Teacher) {
(all x,y: (one Class) {
((((t->x) in Teaches) && ((t->y) in Teaches)) => (x = y))
})
})
}

pred inv8_correct_13[] {
(all c1,c2: (one Class) {
(all t: (one Teacher) {
((((t->c1) in Teaches) && ((t->c2) in Teaches)) => (c1 = c2))
})
})
}

pred inv8_correct_14[] {
(all c1,c2: (one Class),t: (one Teacher) {
((((t->c1) in Teaches) && ((t->c2) in Teaches)) => (c1 = c2))
})
}

pred inv8_correct_15[] {
(((~(Teacher <: Teaches)).(Teacher <: Teaches)) in iden)
}

pred inv8_correct_16[] {
(all t: (one Teacher),c1,c2: (one Class) {
(((c1 in (t.Teaches)) && (c2 in (t.Teaches))) => (c1 = c2))
})
}

pred inv8_correct_17[] {
(all x: (one Teacher),y,t: (one Class) {
((((x->y) in Teaches) && ((x->t) in Teaches)) => (y = t))
})
}

pred inv8_correct_18[] {
(all x: (one Teacher) {
(all c: (one Class) {
(all d: (one Class) {
((((x->c) in Teaches) && (c != d)) => ((x->d) !in Teaches))
})
})
})
}

pred inv8_correct_19[] {
(all t: (one Teacher),x,y: (one Class) {
((((t->x) in Teaches) && ((t->y) in Teaches)) => (x = y))
})
}

pred inv8_correct_20[] {
(all t: (one Teacher),c,u: (one Class) {
((((t->c) in Teaches) && ((t->u) in Teaches)) => (c = u))
})
}

