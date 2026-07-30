module alloy4fun_augmented_classroom_rl_inv5
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv5_oracle[] {
some Teacher.Teaches
}

pred inv5_correct_0[] {
some t:Teacher | some t.Teaches
}

pred inv5_correct_1[] {
Teacher.Teaches != none
}

pred inv5_correct_2[] {
some c : Class | c in Teacher.Teaches
}

pred inv5_correct_3[] {
some (Class & Teacher.Teaches)
}

pred inv5_correct_4[] {
some Teacher <: Teaches
}

pred inv5_correct_5[] {
some c : Class, p : Teacher | c in p.Teaches
}

pred inv5_correct_6[] {
some Teacher.Teaches & Class
}

pred inv5_correct_7[] {
some p : Person, c : Class | p in Teacher and p -> c in Teaches
}

pred inv5_correct_8[] {
some c : Class, p : Person | c in (p.Teaches) and p in Teacher
}

pred inv5_correct_9[] {
some c:Class, t:Teacher | t->c in Teaches
}

pred inv5_correct_10[] {
some c: Class | some t: Teacher | t->c in Teaches
}

pred inv5_correct_11[] {
some (Teacher & Teaches.Class)
}

pred inv5_correct_12[] {
some c : Class, t : Teacher | c in t.Teaches
}

pred inv5_correct_13[] {
some Class.~Teaches&Teacher
}

pred inv5_correct_14[] {
some (Teaches . Class & Teacher)
}

