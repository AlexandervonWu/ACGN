module alloy4fun_augmented_classroom_rl_inv15
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv15_oracle[] {
all p:Person | some Teacher&(^Tutors).p
}

pred inv15_correct_0[] {
all p:Person | some ^Tutors.p & Teacher
}

pred inv15_correct_1[] {
all p : Person | some (p.^(~Tutors) & Teacher)
}

pred inv15_correct_2[] {
all p1 : Person | some p2, p3 : Person |
  (p2->p1 in Tutors) and ((p2 in Teacher) or
  (p3->p2 in Tutors) and ((p3 in Teacher) or
  (p1->p3 in Tutors) and  (p1 in Teacher)))
}

pred inv15_correct_3[] {
all s:Person |some  (^Tutors.s & Teacher)
}

pred inv15_correct_4[] {
all s : Person | some Teacher & ^Tutors.s
}

pred inv15_correct_5[] {
all p:Person | some t:Teacher | t in p.^~Tutors
}

pred inv15_correct_6[] {
all p : Person | p in Teacher.^Tutors
}

pred inv15_correct_7[] {
all p : Person | some Teacher <: (^ Tutors) . p
}

pred inv15_correct_8[] {
all p:Person | some Teacher <: (p.^~Tutors)
}

