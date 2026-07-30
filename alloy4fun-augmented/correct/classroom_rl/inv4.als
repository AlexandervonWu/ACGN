module alloy4fun_augmented_classroom_rl_inv4
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv4_oracle[] {
Person in Student + Teacher
}

pred inv4_correct_0[] {
no ((Person-Student)-Teacher)
}

pred inv4_correct_1[] {
Person = Teacher + Student
}

pred inv4_correct_2[] {
not some p:Person | p not in Student and p not in Teacher
}

pred inv4_correct_3[] {
Person = Student+Teacher
}

pred inv4_correct_4[] {
Teacher + Student = Person
}

pred inv4_correct_5[] {
all p : Person | (p in Teacher) or (p in Student)
}

pred inv4_correct_6[] {
no p:Person | p not in Student and p not in Teacher
}

pred inv4_correct_7[] {
all p : Person | p in Student or p in Teacher
  
  
  Person = Student + Teacher
}

pred inv4_correct_8[] {
Person in Teacher + Student
}

pred inv4_correct_9[] {
all p:Person | not (p not in Student and p not in Teacher)
}

pred inv4_correct_10[] {
all p:Person | p in Student or p in Teacher
}

pred inv4_correct_11[] {
Person - Teacher in Student
}

pred inv4_correct_12[] {
Student + Teacher = Person
}

pred inv4_correct_13[] {
all p : Person | p not in Student => p in Teacher || p not in Teacher => p in Student
}

pred inv4_correct_14[] {
all p : Person | p in Student + Teacher
}

pred inv4_correct_15[] {
all p : Person | not(not p in Student and not p in Teacher)
}

pred inv4_correct_16[] {
no p:Person | p not in Teacher and p not in Student
}

pred inv4_correct_17[] {
no Person - (Teacher + Student)
}

pred inv4_correct_18[] {
no (Person - Student) & (Person - Teacher)
}

pred inv4_correct_19[] {
no Person - (Student + Teacher)
}

pred inv4_correct_20[] {
Person - Student in Teacher
}

