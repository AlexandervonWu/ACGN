module alloy4fun_augmented_classroom_rl_inv9
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
all c:Class | lone Teaches.c & Teacher
}

pred inv9_correct_1[] {
let R = Teacher <: Teaches | R.~R in iden
}

pred inv9_correct_2[] {
all c:Class | lone c.~Teaches&Teacher
}

pred inv9_correct_3[] {
all c : Class | lone t : Teacher | t->c in Teaches
}

pred inv9_correct_4[] {
all c : Class | #(Teacher->c & Teaches) < 2
}

pred inv9_correct_5[] {
all t1,t2:Teacher, c:Class | t1->c in Teaches and t2->c in Teaches implies t1=t2
}

pred inv9_correct_6[] {
all c:Class | lone Teaches.c:>Teacher
}

pred inv9_correct_7[] {
all c : Class, disj t1,t2 : Teacher | not c in (t1.Teaches & t2.Teaches)
}

pred inv9_correct_8[] {
all c:Class { lone t:Teacher | t in c.~Teaches}
}

pred inv9_correct_9[] {
all c: Class | lone Teacher :> Teaches.c
}

pred inv9_correct_10[] {
(Teacher->Teacher) & Teaches.~Teaches in iden
}

pred inv9_correct_11[] {
all c : Class | lone Teacher -> c & Teaches
}

pred inv9_correct_12[] {
(Teacher <: Teaches).~(Teacher <: Teaches) in iden
}

pred inv9_correct_13[] {
all t1, t2:Teacher | all c:Class | t1->c in Teaches and t2->c in Teaches implies t1 = t2
}

pred inv9_correct_14[] {
all c: Class, t1, t2: Teacher | c in t1.Teaches and c in t2.Teaches implies t1 = t2
}

pred inv9_correct_15[] {
(Teacher <: Teaches) . (~Teaches :> Teacher) in iden
}

pred inv9_correct_16[] {
all c:Class,t1,t2:Teacher | t1->c in Teaches and t2->c in Teaches implies t1=t2
}

pred inv9_correct_17[] {
all c : Class, t, t1 : Teacher | t->c + t1->c in Teaches => t = t1
}

pred inv9_correct_18[] {
all c : Class { lone t : Teacher | c in t.Teaches }
}

pred inv9_correct_19[] {
all t : Teacher, y : Teacher | all c : Class | t->c in Teaches and y->c in Teaches implies t=y
}

pred inv9_correct_20[] {
all c: Class | all x, y: Teacher | c in x.Teaches and c in y.Teaches implies x = y
}

pred inv9_correct_21[] {
no c : Class | #(Teacher & Teaches.c) > 1
}

pred inv9_correct_22[] {
Teaches.~Teaches & Teacher->Teacher in iden
}

pred inv9_correct_23[] {
no c : Class | some disj t1,t2 : Teacher | c in t1.Teaches and c in t2.Teaches
}

pred inv9_correct_24[] {
all t1: Teacher, t2: Teacher, c:Class | (t1->c in Teaches and t2->c in Teaches) implies t1 = t2
}

pred inv9_correct_25[] {
all c : Class | (#Teaches.c & Teacher) < 2
}

pred inv9_correct_26[] {
let t = Teacher <: Teaches | t.~t in iden
}

