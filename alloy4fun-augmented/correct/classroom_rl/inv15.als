module alloy4fun_augmented_classroom_rl_inv15
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

pred inv15_oracle[] {
(all s: (one Person) {
(some (Teacher & ((^Tutors).s)))
})
}

pred inv15_correct_0[] {
(all p: (one Person) {
(some t: (one Teacher) {
(t in (p.(^(~Tutors))))
})
})
}

pred inv15_correct_1[] {
(all p1: (one Person) {
((some p2: (one Teacher) {
((p2->p1) in Tutors)
}) || (some p2,p3: (one Person) {
(((p2->p1) in Tutors) && ((p3->p2) in Tutors) && (p3 in Teacher))
}) || (some p2,p3,p4: (one Person) {
(((p2->p1) in Tutors) && ((p3->p2) in Tutors) && ((p4->p3) in Tutors) && (p4 in Teacher))
}))
})
}

pred inv15_correct_2[] {
(all p: (one Person) {
(some q,r: (one Person),t: (one Teacher) {
(((t->p) in Tutors) || (((q->p) in Tutors) && ((t->q) in Tutors)) || (((t->r) in Tutors) && ((r->q) in Tutors) && ((q->p) in Tutors)))
})
})
}

