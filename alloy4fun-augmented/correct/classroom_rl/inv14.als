module alloy4fun_augmented_classroom_rl_inv14
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

pred inv14_oracle[] {
(all s: (one Person),c: (one Class),t: (one Person),g: (one Group) {
((((c->(s->g)) in Groups) && ((t->c) in Teaches)) => ((t->s) in Tutors))
})
}

pred inv14_correct_0[] {
(all s,t: (one Person),c: (one Class) {
(((some g: (one Group) {
((c->(s->g)) in Groups)
}) && ((t->c) in Teaches)) => ((t->s) in Tutors))
})
}

pred inv14_correct_1[] {
(all c: (one Class),g: (one Group),p1,p2: (one Person) {
((((p1->c) in Teaches) && ((c->(p2->g)) in Groups)) => ((p1->p2) in Tutors))
})
}

pred inv14_correct_2[] {
(all s,t: (one Person) {
(all c: (one Class) {
(all g: (one Group) {
((((c->(s->g)) in Groups) && ((t->c) in Teaches)) => ((t->s) in Tutors))
})
})
})
}

pred inv14_correct_3[] {
(all p1,p2: (one Person),c: (one Class),g: (one Group) {
((((c->(p1->g)) in Groups) && ((p2->c) in Teaches)) => ((p2->p1) in Tutors))
})
}

pred inv14_correct_4[] {
(all p1,p2: (one Person),c: (one Class) {
((some g: (one Group) {
((c->(p1->g)) in Groups)
}) => (((p2->c) in Teaches) => ((p2->p1) in Tutors)))
})
}

pred inv14_correct_5[] {
(all p,q: (one Person),c: (one Class) {
(((some g: (one Group) {
((c->(p->g)) in Groups)
}) && ((q->c) in Teaches)) => ((q->p) in Tutors))
})
}

pred inv14_correct_6[] {
(all s: (one Person),c: (one Class) {
((some g: (one Group) {
((c->(s->g)) in Groups)
}) => (all t: (one Person) {
(((t->c) in Teaches) => ((t->s) in Tutors))
}))
})
}

pred inv14_correct_7[] {
(all p: (one Person),c: (one Class) {
((some g: (one Group) {
((c->(p->g)) in Groups)
}) => (all t: (one Person) {
(((t->c) in Teaches) => ((t->p) in Tutors))
}))
})
}

pred inv14_correct_8[] {
(all c: (one Class),s,t: (one Person) {
(all g: (one Group) {
((((c->(s->g)) in Groups) && ((t->c) in Teaches)) => ((t->s) in Tutors))
})
})
}

pred inv14_correct_9[] {
(all p1,p2: (one Person),c: (one Class) {
((some g: (one Group) {
(((c->(p2->g)) in Groups) && ((p1->c) in Teaches))
}) => ((p1->p2) in Tutors))
})
}

pred inv14_correct_10[] {
(all s: (one Person),c: (one Class),g: (one Group),t: (one Person) {
((((c->(s->g)) in Groups) && ((t->c) in Teaches)) => ((t->s) in Tutors))
})
}

pred inv14_correct_11[] {
(all x,v: (one Person),y: (one Class) {
(((some z: (one Group) {
((y->(x->z)) in Groups)
}) && ((v->y) in Teaches)) => ((v->x) in Tutors))
})
}

pred inv14_correct_12[] {
(all ps: (one Person),t: (one Person) {
(all c: (one Class),g: (one Group) {
((((c->(ps->g)) in Groups) && ((t->c) in Teaches)) => ((t->ps) in Tutors))
})
})
}

pred inv14_correct_13[] {
(all p1,p2: (one Person),c: (one Class) {
(((some g: (one Group) {
((c->(p2->g)) in Groups)
}) && ((p1->c) in Teaches)) => ((p1->p2) in Tutors))
})
}

pred inv14_correct_14[] {
(all p: (one Person),c: (one Class) {
((some (p.(c.Groups))) => ((Teaches.c) in (Tutors.p)))
})
}

pred inv14_correct_15[] {
(all s,t: (one Person),c: (one Class),g: (one Group) {
((((c->(s->g)) in Groups) && ((t->c) in Teaches)) => ((t->s) in Tutors))
})
}

pred inv14_correct_16[] {
(all s: (one Person),c: (one Class),t: (one Person) {
(((some g: (one Group) {
((c->(s->g)) in Groups)
}) && ((t->c) in Teaches)) => ((t->s) in Tutors))
})
}

pred inv14_correct_17[] {
(all s: (one Person),c: (one Class),t: (one Person),g: (one Group) {
((((c->(s->g)) in Groups) && ((t->c) in Teaches)) => ((t->s) in Tutors))
})
}

