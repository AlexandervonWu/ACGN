module alloy4fun_augmented_classroom_fol_inv13
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv13_oracle[] {
Tutors in Teacher -> Student
}

pred inv13_correct_0[] {
all p1,p2:Person | p1->p2 in Tutors implies p1 in Teacher and p2 in Student
}

pred inv13_correct_1[] {
Person.^~Tutors in Teacher and Person.^Tutors in Student
}

pred inv13_correct_2[] {
all p,p1:Person | p->p1 in Tutors implies p in Teacher and p1 in Student
}

pred inv13_correct_3[] {
Person.^Tutors in Student and Person.^~Tutors in Teacher
}

pred inv13_correct_4[] {
all x, y : Person | x -> y in Tutors implies x in Teacher and y in Student
}

pred inv13_correct_5[] {
(all t,s : Person | t->s in Tutors implies( t in Teacher and s in Student))
}

pred inv13_correct_6[] {
all p1:Person, p2:Person | p1->p2 in Tutors implies p1 in Teacher and p2 in Student
}

pred inv13_correct_7[] {
all p1,p2:Person | p2 in p1.Tutors implies p1 in Teacher and p2 in Student
}

pred inv13_correct_8[] {
all p: Person | all s: Person | p->s in Tutors implies p in Teacher and s in Student
}

pred inv13_correct_9[] {
all a, b : Person | a -> b in Tutors implies a in Teacher and b in Student
}

pred inv13_correct_10[] {
all p:Person, p2: Person | p->p2 in Tutors implies (p in Teacher and p2 in Student)
}

pred inv13_correct_11[] {
all p,pp: Person | p->pp in Tutors implies p in Teacher and pp in Student
}

