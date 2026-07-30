module alloy4fun_augmented_classroom_fol_inv6
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv6_oracle[] {
all t:Teacher | some t.Teaches
}

pred inv6_correct_0[] {
all t : Teacher | (#t.Teaches)>0
}

pred inv6_correct_1[] {
all t:Teacher | some c:Class | t->c in Teaches
}

pred inv6_correct_2[] {
Teacher in Class.~Teaches
}

pred inv6_correct_3[] {
all t:Teacher| some x:Class| t->x in Teaches
}

pred inv6_correct_4[] {
all p : Teacher | some c : Class | p -> c in Teaches
}

pred inv6_correct_5[] {
Teacher in Teaches.Class
}

pred inv6_correct_6[] {
all x : Teacher | some c : Class | x->c in Teaches
}

pred inv6_correct_7[] {
all t:Teacher | some c:Class | c in t.Teaches
}

pred inv6_correct_8[] {
all p : Person | p in Teacher => some c : Class | p -> c in Teaches
}

pred inv6_correct_9[] {
all t : Teacher | (some c : Class | teaches_class[t,c])
}

pred inv6_correct_10[] {
all x : Teacher | some y : Class  | x->y in Teaches
}

pred inv6_correct_11[] {
all t:Teacher | t.Teaches != none
}

pred inv6_correct_12[] {
all p:Teacher | some c:Class | p in Teacher implies p->c in Teaches
}

