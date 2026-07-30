module alloy4fun_augmented_classroom_fol_inv1
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
all p:Person | p in Student
}

pred inv1_correct_1[] {
all x : Person | x in Student
}

pred inv1_correct_2[] {
Person = Student
}

pred inv1_correct_3[] {
Student = Person
}

pred inv1_correct_4[] {
all f : Person | f in Student
}

pred inv1_correct_5[] {
(Person & Student) = Person
}

pred inv1_correct_6[] {
no (Person-Student)
}

pred inv1_correct_7[] {
all s : Person | s in Student
}

