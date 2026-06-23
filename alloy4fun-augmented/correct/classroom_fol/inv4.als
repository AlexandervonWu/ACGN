module alloy4fun_augmented_classroom_fol_inv4
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

pred inv4_oracle[] {
(Person in (Student + Teacher))
}

pred inv4_correct_0[] {
(all p: (one Person) {
((p !in Student) => (p in Teacher))
})
}

pred inv4_correct_1[] {
(all p: (one Person) {
(!((p !in Student) && (p !in Teacher)))
})
}

pred inv4_correct_2[] {
(all p: (one Person) {
((p in Student) || (p in Teacher))
})
}

pred inv4_correct_3[] {
(all p: (one Person) {
((p in Teacher) || (p in Student))
})
}

pred inv4_correct_4[] {
(all p: (one Person) {
(!((!(p in Student)) && (!(p in Teacher))))
})
}

pred inv4_correct_5[] {
(Person = (Student + Teacher))
}

pred inv4_correct_6[] {
(Person in (Student + Teacher))
}

pred inv4_correct_7[] {
(all p: (one Person) {
(((p !in Student) => (p in Teacher)) && ((p !in Teacher) => (p in Student)))
})
}

pred inv4_correct_8[] {
(all p: (one Person) {
(p in (Student + Teacher))
})
}

pred inv4_correct_9[] {
(all f: (one Person) {
(f in (Student + Teacher))
})
}

pred inv4_correct_10[] {
(Person in (Teacher + Student))
}

pred inv4_correct_11[] {
(all x: (one Person) {
((x !in Student) => (x in Teacher))
})
}

pred inv4_correct_12[] {
(all x: (one Person) {
((x in Student) || (x in Teacher))
})
}

pred inv4_correct_13[] {
(all w: (one Person) {
((w in Student) || (w in Teacher))
})
}

pred inv4_correct_14[] {
(no ((Person - Student) - Teacher))
}

pred inv4_correct_15[] {
((Person = (Student + Teacher)) && (all x: (one Person) {
((x in Student) || (x in Teacher))
}))
}

pred inv4_correct_16[] {
(Person = (Teacher + Student))
}

