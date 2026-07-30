module alloy4fun_augmented_classroom_fol_inv3
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
no Teacher & Student
}

pred inv3_correct_1[] {
not some p:Person | p in Student and p in Teacher
}

pred inv3_correct_2[] {
all p : Person | p in Student implies p not in Teacher
}

pred inv3_correct_3[] {
all p: Person | not (p in Teacher and p in Student)
}

pred inv3_correct_4[] {
all p:Person | p in Teacher implies p not in Student
}

pred inv3_correct_5[] {
all p : Person {
  (p in Student implies p not in Teacher)
  or
  (p in Teacher implies p not in Student)
  }
}

pred inv3_correct_6[] {
all x : Student | x not in Teacher
}

pred inv3_correct_7[] {
all p : Person | (p in Teacher implies p not in Student) and (p in Student implies p not in Teacher)
}

pred inv3_correct_8[] {
all w : Person | w in Student implies w not in Teacher
  all w : Person | w in Teacher implies w not in Student
}

pred inv3_correct_9[] {
all p : Person | p in Teacher implies p not in Student or p  in Student implies p not in Teacher
}

pred inv3_correct_10[] {
Student in Person - Teacher  
  	Teacher in Person - Student
}

pred inv3_correct_11[] {
all p : Person | p not in (Student & Teacher)
}

pred inv3_correct_12[] {
no p:Person | p in Student and p in Teacher
}

pred inv3_correct_13[] {
all p : Person | p not in Student or p not in Teacher
}

pred inv3_correct_14[] {
all x,y : Person | x in Student and y in Teacher implies x not in Teacher and y not in Student
}

pred inv3_correct_15[] {
Student & Teacher = none
}

pred inv3_correct_16[] {
all s:Student | s not in Teacher
}

pred inv3_correct_17[] {
all s: Student | all t: Teacher | s not in Teacher and t not in Student
}

pred inv3_correct_18[] {
no p:Person | p in Teacher and p in Student
}

pred inv3_correct_19[] {
all s:Student,t:Teacher | s!=t
}

pred inv3_correct_20[] {
all p,q:Person | p in Teacher and q in Student implies p != q
}

pred inv3_correct_21[] {
all p : Person | p in Student implies p not in Teacher
  	all p : Person | p in Teacher implies p not in Student
}

pred inv3_correct_22[] {
all x : Person | x in Student implies x not in Teacher
}

pred inv3_correct_23[] {
no p1:Student,p2:Teacher | p1=p2
}

pred inv3_correct_24[] {
not some p:Person | p in Teacher and p in Student
}

pred inv3_correct_25[] {
all p : Person | (p in Student implies p not in Teacher) and (p in Teacher implies p not in Student)
}

pred inv3_correct_26[] {
all p:Person | p in Teacher implies p not in Student or p in Student and p not in Teacher
}

pred inv3_correct_27[] {
all p : Person | not (p in Student and p in Teacher)
}

pred inv3_correct_28[] {
all t:Teacher | t not in Student
}

pred inv3_correct_29[] {
Student in Person - Teacher  
  	Teacher in Person - Student
    all x : Person | x in Student implies x not in Teacher
}

