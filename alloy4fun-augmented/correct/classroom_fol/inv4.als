module alloy4fun_augmented_classroom_fol_inv4
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
Person = Teacher+Student
}

pred inv4_correct_1[] {
no p:Person | p not in Teacher and p not in Student
}

pred inv4_correct_2[] {
Person in Teacher + Student
}

pred inv4_correct_3[] {
all p:Person | p in Student or p in Teacher
}

pred inv4_correct_4[] {
no (Person-Student-Teacher)
}

pred inv4_correct_5[] {
all p : Person | p in Teacher or p in Student
}

pred inv4_correct_6[] {
not some p : Person | not p in Student and not p in Teacher
}

pred inv4_correct_7[] {
all p:Person | not (p not in Student and p not in Teacher)
}

pred inv4_correct_8[] {
not some p:Person | not p in Teacher and not p in Student
}

pred inv4_correct_9[] {
all p : Person | (p not in Student implies p in Teacher) and (p not in Teacher implies p in Student)
}

pred inv4_correct_10[] {
all x : Person | x not in Student implies x in Teacher
}

pred inv4_correct_11[] {
all f : Person | f in (Student + Teacher)
}

pred inv4_correct_12[] {
all w : Person | w in Student or w in Teacher
}

pred inv4_correct_13[] {
Person = Student + Teacher
}

pred inv4_correct_14[] {
all x : Person | x in Student or x in Teacher
}

pred inv4_correct_15[] {
all p : Person | p in (Student + Teacher)
}

pred inv4_correct_16[] {
not some p:Person | p not in Student and p not in Teacher
}

pred inv4_correct_17[] {
no p:Person | p not in Student and p not in Teacher
}

pred inv4_correct_18[] {
all p:Person | p not in Student implies p in Teacher
}

pred inv4_correct_19[] {
Student + Teacher = Person
}

pred inv4_correct_20[] {
no p:Person | not p in Teacher and not p in Student
}

pred inv4_correct_21[] {
all p : Person | not(not p in Student and not p in Teacher)
}

pred inv4_correct_22[] {
Person = Student + Teacher
  	all x : Person | x in Student or x in Teacher
}

