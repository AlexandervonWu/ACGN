module alloy4fun_augmented_classroom_rl_inv2
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

pred inv2_oracle[] {
(no Teacher)
}

pred inv2_correct_0[] {
(all p: (one Person) {
(p !in Teacher)
})
}

pred inv2_correct_1[] {
(all t: (one Teacher) {
(t !in Teacher)
})
}

pred inv2_correct_2[] {
(no Teacher)
}

pred inv2_correct_3[] {
(always (no Teacher))
}

pred inv2_correct_4[] {
(all t: (one Person) {
(t !in Teacher)
})
}

pred inv2_correct_5[] {
(all x: (one Person) {
(x !in Teacher)
})
}

pred inv2_correct_6[] {
(all f: (one Person) {
(f !in Teacher)
})
}

