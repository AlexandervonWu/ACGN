module alloy4fun_augmented_classroom_fol_inv2
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv2_oracle[] {
no Teacher
}

pred inv2_correct_0[] {
all p:Person | not p in Teacher
}

pred inv2_correct_1[] {
all t : Teacher | t not in Teacher
}

pred inv2_correct_2[] {
all p : Person | p not in Teacher
}

pred inv2_correct_3[] {
always (no Teacher)
}

pred inv2_correct_4[] {
all x : Person | x not in Teacher
}

pred inv2_correct_5[] {
not some p:Person | p in Teacher
}

pred inv2_correct_6[] {
Teacher = none
}

pred inv2_correct_7[] {
Person - Teacher = Person
}

pred inv2_correct_8[] {
Person = (Person - Teacher)
}

pred inv2_correct_9[] {
no p:Person | p in Teacher
}

pred inv2_correct_10[] {
all f : Person | f not in Teacher
}

pred inv2_correct_11[] {
no Person & Teacher
}

