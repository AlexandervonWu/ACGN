module alloy4fun_augmented_classroom_rl_inv1
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv1_oracle[] {
Person in Student
}

pred inv1_correct_0[] {
no Person - Student
}

pred inv1_correct_1[] {
Person = Student
}

pred inv1_correct_2[] {
all p : Person | p in Student
}

pred inv1_correct_3[] {
all p : Person | p in Student
  
  
  Person in Student
}

pred inv1_correct_4[] {
Student = Person
}

pred inv1_correct_5[] {
all p: Person | Person in Student
}

pred inv1_correct_6[] {
Person - Student = none
}

pred inv1_correct_7[] {
all p : Person | some (p & Student)
}

pred inv1_correct_8[] {
all f: Person | f in Student
}

