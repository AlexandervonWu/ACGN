module alloy4fun_augmented_classroom_rl_inv13
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

pred inv13_oracle[] {
(((Tutors.Person) in Teacher) && ((Person.Tutors) in Student))
}

pred inv13_correct_0[] {
(all p1,p2: (one Person) {
(((p1->p2) in Tutors) => ((p1 in Teacher) && (p2 in Student)))
})
}

pred inv13_correct_1[] {
(all p,pp: (one Person) {
(((p->pp) in Tutors) => ((p in Teacher) && (pp in Student)))
})
}

pred inv13_correct_2[] {
(all x,y: (one Person) {
(((x->y) in Tutors) => ((x in Teacher) && (y in Student)))
})
}

pred inv13_correct_3[] {
(all p: (one Person) {
(all s: (one Person) {
(((p->s) in Tutors) => ((p in Teacher) && (s in Student)))
})
})
}

pred inv13_correct_4[] {
(all p1: (one Person),p2: (one Person) {
(((p1->p2) in Tutors) => ((p1 in Teacher) && (p2 in Student)))
})
}

pred inv13_correct_5[] {
(all p,p1: (one Person) {
(((p->p1) in Tutors) => ((p in Teacher) && (p1 in Student)))
})
}

pred inv13_correct_6[] {
(((Person.(^(~Tutors))) in Teacher) && ((Person.(^Tutors)) in Student))
}

pred inv13_correct_7[] {
(all t,s: (one Person) {
(((t->s) in Tutors) => ((t in Teacher) && (s in Student)))
})
}

pred inv13_correct_8[] {
(all a,b: (one Person) {
(((a->b) in Tutors) => ((a in Teacher) && (b in Student)))
})
}

pred inv13_correct_9[] {
(all p1,p2: (one Person) {
((p2 in (p1.Tutors)) => ((p1 in Teacher) && (p2 in Student)))
})
}

pred inv13_correct_10[] {
(((Person.(^Tutors)) in Student) && ((Person.(^(~Tutors))) in Teacher))
}

pred inv13_correct_11[] {
(all p: (one Person),p2: (one Person) {
(((p->p2) in Tutors) => ((p in Teacher) && (p2 in Student)))
})
}

pred inv13_correct_12[] {
(all p: (one Person),t: (one (p.Tutors)) {
(((p->t) in Tutors) => ((p in Teacher) && (t in Student)))
})
}

