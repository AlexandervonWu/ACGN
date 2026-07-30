module alloy4fun_augmented_classroom_rl_inv6
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv6_oracle[] {
all t:Teacher | some t.Teaches
}

pred inv6_correct_0[] {
Teacher in Teaches.Class
}

pred inv6_correct_1[] {
all t : Teacher | #t.Teaches > 0
}

pred inv6_correct_2[] {
all t: Teacher | t.Teaches != none
}

pred inv6_correct_3[] {
all p : Person | p in Teacher implies some p.Teaches
}

pred inv6_correct_4[] {
Teacher in Class.~Teaches
}

pred inv6_correct_5[] {
iden & Teacher->Teacher in Teaches.~Teaches
}

pred inv6_correct_6[] {
all t : Teacher | some c : Class | t->c in Teaches
}

pred inv6_correct_7[] {
all p:Teacher | some c:Class | p->c in Teaches
}

pred inv6_correct_8[] {
Teacher in Class.~Teaches
  	Teacher in Teaches.Class
}

pred inv6_correct_9[] {
(Teaches.Class & Teacher) = Teacher
}

pred inv6_correct_10[] {
all t : Teacher | some c : Class | c in t.Teaches
}

pred inv6_correct_11[] {
Teacher in Teacher.Teaches.~Teaches
}

pred inv6_correct_12[] {
all t: Teacher | not no t.Teaches
}

