module alloy4fun_augmented_classroom_fol_inv7
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv7_oracle[] {
all c:Class | some Teacher&Teaches.c
}

pred inv7_correct_0[] {
all c:Class | some t:Teacher | t->c in Teaches
}

pred inv7_correct_1[] {
all c:Class | some t:Teacher | t in c.~Teaches
}

pred inv7_correct_2[] {
all c: Class | some p:Person | p in Teacher and p->c in Teaches
}

pred inv7_correct_3[] {
all c : Class | some p : Teacher | p -> c in Teaches
}

pred inv7_correct_4[] {
Class in Teacher.Teaches
}

pred inv7_correct_5[] {
all c : Class | some x : Teacher | x->c in Teaches
}

pred inv7_correct_6[] {
Teacher.Teaches = Class
}

pred inv7_correct_7[] {
all x: Class | some t :Teacher | t->x in Teaches
}

pred inv7_correct_8[] {
all y : Class | some x : Teacher | x->y in Teaches
}

pred inv7_correct_9[] {
all c:Class | some t:Teacher | t in Teaches.c
}

pred inv7_correct_10[] {
all c : Class | c in Teacher.Teaches
}

pred inv7_correct_11[] {
all c:Class | some t:Teacher | t in c.~Teaches
  	Class in Teacher.Teaches
}

pred inv7_correct_12[] {
all c:Class | some( c.~Teaches & Teacher)
}

pred inv7_correct_13[] {
all x : Class | some y : Teacher | y->x in Teaches
}

pred inv7_correct_14[] {
all c:Class | some t:Teacher | c in t.Teaches
}

pred inv7_correct_15[] {
not some c : Class | all t : Teacher | not t->c in Teaches
}

