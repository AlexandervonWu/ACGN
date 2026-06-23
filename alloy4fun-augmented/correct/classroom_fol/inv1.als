module alloy4fun_augmented_classroom_fol_inv1
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

pred inv1_oracle[] {
(Person in Student)
}

pred inv1_correct_0[] {
(Person in Student)
}

pred inv1_correct_1[] {
(all p: (one Person) {
(p in Student)
})
}

pred inv1_correct_2[] {
(all x: (one Person) {
(x in Student)
})
}

pred inv1_correct_3[] {
(all s: (one Person) {
(s in Student)
})
}

pred inv1_correct_4[] {
(no (Person - Student))
}

pred inv1_correct_5[] {
(Person = Student)
}

pred inv1_correct_6[] {
(all f: (one Person) {
(f in Student)
})
}

