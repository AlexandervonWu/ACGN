module alloy4fun_augmented_classroom_rl_inv3
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv3_oracle[] {
no Student & Teacher
}

pred inv3_correct_0[] {
Student & Teacher = none
}

pred inv3_correct_1[] {
(Student-Teacher) = Student
}

pred inv3_correct_2[] {
all p : Person | p in Student implies p not in Teacher
}

pred inv3_correct_3[] {
no Student & Teacher & Person
}

pred inv3_correct_4[] {
no p : Person | p in Student and p in Teacher
}

pred inv3_correct_5[] {
no (Teacher&Student)
}

pred inv3_correct_6[] {
all p : Person | p not in Student or p not in Teacher
}

pred inv3_correct_7[] {
not some s: Student, t: Teacher | s = t
}

pred inv3_correct_8[] {
not some p:Person | p in Student and p in Teacher
}

pred inv3_correct_9[] {
all p : Person | p not in (Student & Teacher)
}

pred inv3_correct_10[] {
all p1, p2: Person | p1 in Student and p2 in Teacher implies p1 != p2
}

pred inv3_correct_11[] {
no p:Person | p in Teacher and p in Student
}

pred inv3_correct_12[] {
all s: Student | no t: Teacher | s = t
}

pred inv3_correct_13[] {
all p : Person | p in Student => p not in Teacher || p in Teacher => p not in Student
}

pred inv3_correct_14[] {
all p: Person | (p in Teacher) => (p !in Student)
}

pred inv3_correct_15[] {
all p: Person | (p in Student and p not in Teacher) or (p in Teacher and p not in Student) or p not in (Student + Teacher)
}

pred inv3_correct_16[] {
all p : Person | (p in Student implies p not in Teacher) or ( p in Teacher implies p not in Student) 
  
  
  
  no (Teacher & Student)
}

pred inv3_correct_17[] {
all s: Student | s not in Teacher
}

pred inv3_correct_18[] {
all p:Person | not (p in Student and p in Teacher)
}

pred inv3_correct_19[] {
all p : Person | p in Teacher => p not in Student || p in Student => p not in Teacher
}

pred inv3_correct_20[] {
all p1, p2: univ | p1 in Student and p2 in Teacher implies p1 != p2
}

