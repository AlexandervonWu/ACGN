module alloy4fun_augmented_classroom_rl_inv2
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
Teacher = none
}

pred inv2_correct_1[] {
no p:Person | p in Teacher
}

pred inv2_correct_2[] {
all p:Person | p not in Teacher
}

pred inv2_correct_3[] {
not some p:Person | p in Teacher
}

pred inv2_correct_4[] {
all p : Person | p not in Teacher
  
  
  
  no Teacher
}

pred inv2_correct_5[] {
no Person&Teacher
}

