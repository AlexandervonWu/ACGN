module alloy4fun_augmented_classroom_fol_inv9
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

pred inv9_oracle[] {
(all c: (one Class) {
(lone ((Teaches.c) & Teacher))
})
}

pred inv9_correct_0[] {
(all c: (one Class) {
(all t1,t2: (one Teacher) {
((((t1->c) in Teaches) && ((t2->c) in Teaches)) => (t1 = t2))
})
})
}

pred inv9_correct_1[] {
(all c: (one Class),t1,t2: (one Teacher) {
((((t1->c) in Teaches) && ((t2->c) in Teaches)) => (t1 = t2))
})
}

pred inv9_correct_2[] {
(all t1: (one Teacher),t2: (one Teacher),c: (one Class) {
((((t1->c) in Teaches) && ((t2->c) in Teaches)) => (t1 = t2))
})
}

pred inv9_correct_3[] {
(all c: (one Class) {
(all x,y: (one Teacher) {
((((x->c) in Teaches) && ((y->c) in Teaches)) => (x = y))
})
})
}

pred inv9_correct_4[] {
(all t1,t2: (one Teacher),c: (one Class) {
((((t1->c) in Teaches) && ((t2->c) in Teaches)) => (t1 = t2))
})
}

pred inv9_correct_5[] {
(all c: (one Class),t,u: (one Teacher) {
((((t->c) in Teaches) && ((u->c) in Teaches)) => (t = u))
})
}

pred inv9_correct_6[] {
(all x: (one Class),y,z: (one Teacher) {
((((y->x) in Teaches) && ((z->x) in Teaches)) => (y = z))
})
}

pred inv9_correct_7[] {
(all c: (one Class) {
(all t,u: (one Teacher) {
((((t->c) in Teaches) && ((u->c) in Teaches)) => (t = u))
})
})
}

pred inv9_correct_8[] {
(all c: (one Class) {
(lone t: (one Teacher) {
((t->c) in Teaches)
})
})
}

pred inv9_correct_9[] {
(all c: (one Class) {
(lone ((c.(~Teaches)) & Teacher))
})
}

pred inv9_correct_10[] {
(all c: (one Class),t,t1: (one Teacher) {
((((t->c) in Teaches) && ((t1->c) in Teaches)) => (t = t1))
})
}

pred inv9_correct_11[] {
(all c: (one Class) {
((#((Teacher->c) & Teaches)) < 2)
})
}

pred inv9_correct_12[] {
(all t1,t2: (one Teacher) {
(all c: (one Class) {
((((t1->c) in Teaches) && ((t2->c) in Teaches)) => (t1 = t2))
})
})
}

pred inv9_correct_13[] {
(all c: (one Class) {
(lone ((Teaches.c) & Teacher))
})
}

pred inv9_correct_14[] {
(all x: (one Class),t,t1: (one Teacher) {
((((t->x) in Teaches) && ((t1->x) in Teaches)) => (t = t1))
})
}

pred inv9_correct_15[] {
(((Teacher <: Teaches).(~(Teacher <: Teaches))) in iden)
}

pred inv9_correct_16[] {
(all c: (one Class) {
(lone t: (one Teacher) {
(c in (t.Teaches))
})
})
}

pred inv9_correct_17[] {
(all c: (one Class) {
(all t,x: (one Teacher) {
((((t->c) in Teaches) && ((x->c) in Teaches)) => (t = x))
})
})
}

pred inv9_correct_18[] {
(all c: (one Class) {
(all y,z: (one Teacher) {
((((y->c) in Teaches) && ((z->c) in Teaches)) => (z = y))
})
})
}

pred inv9_correct_19[] {
(all c: (one Class),y,z: (one Teacher) {
((((y->c) in Teaches) && ((z->c) in Teaches)) => (z = y))
})
}

pred inv9_correct_20[] {
(all t: (one Teacher),y: (one Teacher) {
(all c: (one Class) {
((((t->c) in Teaches) && ((y->c) in Teaches)) => (t = y))
})
})
}

pred inv9_correct_21[] {
(all c: (one Class),x,y: (one Teacher) {
((((y->c) in Teaches) && ((x->c) in Teaches)) => (x = y))
})
}

pred inv9_correct_22[] {
(all x,y: (one Teacher),z: (one Class) {
((((x->z) in Teaches) && ((y->z) in Teaches)) => (x = y))
})
}

