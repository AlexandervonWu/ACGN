module alloy4fun_augmented_classroom_fol_inv3
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

pred inv3_oracle[] {
(no (Student & Teacher))
}

pred inv3_correct_0[] {
(!(some p: (one Person) {
((p in Student) && (p in Teacher))
}))
}

pred inv3_correct_1[] {
(no (Teacher & Student))
}

pred inv3_correct_2[] {
(all p: (one Person) {
(((p in Student) => (p !in Teacher)) || ((p in Teacher) => (p !in Student)))
})
}

pred inv3_correct_3[] {
(all x: (one Person) {
((x in Student) => (x !in Teacher))
})
}

pred inv3_correct_4[] {
((all w: (one Person) {
((w in Student) => (w !in Teacher))
}) && (all w: (one Person) {
((w in Teacher) => (w !in Student))
}))
}

pred inv3_correct_5[] {
(all p: (one Person) {
(!((p in Teacher) && (p in Student)))
})
}

pred inv3_correct_6[] {
(no t: (one Teacher) {
(t in Student)
})
}

pred inv3_correct_7[] {
(all p: (one Person) {
((p in Student) => (p !in Teacher))
})
}

pred inv3_correct_8[] {
(all p: (one Person) {
(((p in Teacher) => (p !in Student)) && ((p in Student) => (p !in Teacher)))
})
}

pred inv3_correct_9[] {
(all p: (one Person) {
(p !in (Student & Teacher))
})
}

pred inv3_correct_10[] {
(all p: (one Person) {
(((p in Teacher) => (p !in Student)) || ((p in Student) => (p !in Teacher)))
})
}

pred inv3_correct_11[] {
(no (Student & Teacher))
}

pred inv3_correct_12[] {
(all p: (one Person) {
(!((p in Student) && (p in Teacher)))
})
}

pred inv3_correct_13[] {
(all p,q: (one Person) {
(((p in Teacher) && (q in Student)) => (p != q))
})
}

pred inv3_correct_14[] {
(all s: (one Student) {
(s !in Teacher)
})
}

pred inv3_correct_15[] {
(all x,y: (one Person) {
(((x in Student) && (y in Teacher)) => ((x !in Teacher) && (y !in Student)))
})
}

pred inv3_correct_16[] {
(all p: (one Person) {
((p in Teacher) => (p !in Student))
})
}

pred inv3_correct_17[] {
(all s: (one Student) {
(all t: (one Teacher) {
((s !in Teacher) && (t !in Student))
})
})
}

pred inv3_correct_18[] {
((Student in (Person - Teacher)) && (Teacher in (Person - Student)))
}

pred inv3_correct_19[] {
(all t: (one Teacher) {
(t !in Student)
})
}

pred inv3_correct_20[] {
(all s: (one Student) {
(all t: (one Teacher) {
(t !in Student)
})
})
}

pred inv3_correct_21[] {
(all s: (one Student),t: (one Teacher) {
(s != t)
})
}

pred inv3_correct_22[] {
(all p: (one Person) {
(((p in Student) => (p !in Teacher)) && ((p in Teacher) => (p !in Student)))
})
}

pred inv3_correct_23[] {
(all x: (one Student) {
(x !in Teacher)
})
}

pred inv3_correct_24[] {
(all p: (one Person) {
((p !in Student) || (p !in Teacher))
})
}

pred inv3_correct_25[] {
((Student in (Person - Teacher)) && (Teacher in (Person - Student)) && (all x: (one Person) {
((x in Student) => (x !in Teacher))
}))
}

pred inv3_correct_26[] {
((all p: (one Person) {
((p in Student) => (p !in Teacher))
}) && (all p: (one Person) {
((p in Teacher) => (p !in Student))
}))
}

