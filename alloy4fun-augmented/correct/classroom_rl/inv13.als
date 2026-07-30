module alloy4fun_augmented_classroom_rl_inv13
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv13_oracle[] {
Tutors in Teacher -> Student
}

pred inv13_correct_0[] {
all p : Person, t : p.Tutors | p->t in Tutors => p in Teacher && t in Student
}

pred inv13_correct_1[] {
all s, t: Person | t->s in Tutors implies s in Student and t in Teacher
}

pred inv13_correct_2[] {
Tutors.Person in Teacher and Person.Tutors in Student
}

pred inv13_correct_3[] {
all p : Person, t : p.Tutors | p in Teacher && t in Student
}

pred inv13_correct_4[] {
Person.Tutors in Student and Tutors.Person in Teacher
}

pred inv13_correct_5[] {
(no (Person-Teacher).Tutors) and (no (Tutors.(Person-Student)))
}

pred inv13_correct_6[] {
all p : Person { some p.Tutors implies p in Teacher }
  	all p : Person { some Tutors.p implies p in Student }
}

pred inv13_correct_7[] {
all t,s:Person | t->s in Tutors implies t in Teacher and s in Student
}

pred inv13_correct_8[] {
all p1,p2:Person | p1.Tutors in Student and Tutors.p2 in Teacher
}

pred inv13_correct_9[] {
all p : Person, t : p.Tutors | p in Teacher && p.Tutors in Student
}

pred inv13_correct_10[] {
all p1,p2:Person | p1->p2 in Tutors implies p1 in Teacher and p2 in Student
}

pred inv13_correct_11[] {
all t,s:Person | some Tutors.s:>t implies t in Teacher and s in Student
}

pred inv13_correct_12[] {
Tutors in Teacher <: Tutors :> Student
}

pred inv13_correct_13[] {
Teacher <: Tutors = Tutors && Tutors :> Student = Tutors
}

pred inv13_correct_14[] {
Teacher.Tutors in Student and Tutors.Person in Teacher
}

pred inv13_correct_15[] {
Person.Tutors in Student and Person.~Tutors in Teacher
}

pred inv13_correct_16[] {
all p : Person | some p.Tutors implies p in Teacher  and p.Tutors in Student
}

pred inv13_correct_17[] {
Teacher<:Tutors:>Student = Tutors
}

pred inv13_correct_18[] {
all p, p1 : Person | p->p1 in Tutors implies (p in Teacher and p1 in Student)
}

pred inv13_correct_19[] {
all p:Person | p.Tutors in Student and Tutors.p in Teacher
}

pred inv13_correct_20[] {
all t,s:Person | some  Tutors.s <:t implies s in Student and t in Teacher
}

pred inv13_correct_21[] {
Person.^~Tutors in Teacher and Person.^Tutors in Student
}

pred inv13_correct_22[] {
all p: Person | {((some p.Tutors) => (p in Teacher)) ((some Tutors.p) => (p in Student))}
}

