module alloy4fun_augmented_classroom_fol_inv9
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv9_oracle[] {
all c:Class | lone Teacher&Teaches.c
}

pred inv9_correct_0[] {
all t1:Teacher,t2:Teacher,c:Class | (t1->c in Teaches and t2->c in Teaches) implies t1=t2
}

pred inv9_correct_1[] {
all c : Class, t1,t2 : Teacher | (t1->c in Teaches and t2->c in Teaches) implies t1=t2
}

pred inv9_correct_2[] {
all c:Class | all t1,t2:Teacher | t1->c in Teaches and t2->c in Teaches implies t1=t2
}

pred inv9_correct_3[] {
all t1,t2 : Teacher, c : Class | t1 -> c in Teaches and t2 -> c in Teaches implies t1 = t2
}

pred inv9_correct_4[] {
all x,y: Teacher, z: Class | x->z in Teaches and y->z in Teaches implies x=y
}

pred inv9_correct_5[] {
all c:Class | all t,u : Teacher | t->c in Teaches and u->c in Teaches implies t=u
}

pred inv9_correct_6[] {
all c : Class | all p1, p2 : Person | p1 in Teacher and p2 in Teacher and p1 -> c in Teaches and p2 -> c in Teaches => p1 = p2
}

pred inv9_correct_7[] {
all t : Teacher, y : Teacher | all c : Class | t->c in Teaches and y->c in Teaches implies t=y
}

pred inv9_correct_8[] {
all c : Class, p1, p2 : Person | p1 in Teacher and p2 in Teacher and p1 -> c in Teaches and p2 -> c in Teaches => p1 = p2
}

pred inv9_correct_9[] {
all c:Class | lone t:Teacher | t->c in Teaches
}

pred inv9_correct_10[] {
all c : Class, x, y : Teacher | y->c in Teaches and x->c in Teaches implies x=y
}

pred inv9_correct_11[] {
all c:Class | lone ((c.~Teaches) & Teacher)
}

pred inv9_correct_12[] {
all t1,t2:Teacher | all c:Class | t1->c in Teaches and t2->c in Teaches implies t1=t2
}

pred inv9_correct_13[] {
all x : Class, y,z : Teacher | y->x in Teaches and z->x in Teaches implies y=z
}

pred inv9_correct_14[] {
not some c :Class | some t1,t2 : Teacher | (t1->c in Teaches and t2->c in Teaches) and t1 != t2
}

pred inv9_correct_15[] {
all c:Class, p1, p2: Teacher | p1 -> c in Teaches and p2 -> c in Teaches => p1=p2
}

pred inv9_correct_16[] {
all c : Class | all y, z : Teacher | y->c in Teaches and z->c in Teaches implies z = y
}

pred inv9_correct_17[] {
all c : Class | all t, x : Teacher | t -> c in Teaches and x -> c in Teaches implies t = x
}

pred inv9_correct_18[] {
all x:Class, t,t1:Teacher | t->x in Teaches and t1->x in Teaches implies t=t1
}

pred inv9_correct_19[] {
all c : Class, y, z : Teacher | y->c in Teaches and z->c in Teaches implies z = y
}

pred inv9_correct_20[] {
all c:Class | lone Teaches.c & Teacher
}

pred inv9_correct_21[] {
(Teacher <: Teaches).~(Teacher <: Teaches) in iden
}

pred inv9_correct_22[] {
all c:Class | lone t:Teacher | c in t.Teaches
}

pred inv9_correct_23[] {
all c : Class | all x,y : Teacher | x->c in Teaches and y->c in Teaches implies x=y
}

pred inv9_correct_24[] {
all p1, p2 : Teacher, c : Class | (p1->c in Teaches and p2->c in Teaches) => p1 = p2
}

pred inv9_correct_25[] {
all c : Class | #(Teacher -> c & Teaches)<2
}

pred inv9_correct_26[] {
all c : Class , t,u : Teacher | t->c in Teaches and u->c in Teaches implies t=u
}

pred inv9_correct_27[] {
all p1, p2 : Teacher | all c : Class | (p1->c in Teaches and p2->c in Teaches) => p1 = p2
}

pred inv9_correct_28[] {
all c:Class,p1,p2:Teacher | c in p1.Teaches and c in p2.Teaches implies p1=p2
}

pred inv9_correct_29[] {
all c : Class, t, t1 : Teacher | t->c in Teaches and t1->c in Teaches => t = t1
}

