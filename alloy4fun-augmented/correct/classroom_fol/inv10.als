module alloy4fun_augmented_classroom_fol_inv10
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv10_oracle[] {
all c:Class,s:Student | some s.(c.Groups)
}

pred inv10_correct_0[] {
all c:Class,s:Student|some g:Group| c->s->g in Groups
}

pred inv10_correct_1[] {
all x : Class, s : Student | some g : Group | x->s->g in Groups
}

pred inv10_correct_2[] {
all c : Class | all s : Student | some g : Group | c->s->g in Groups
}

pred inv10_correct_3[] {
all x: Class, y : Student | some z : Group | x->y->z in Groups
}

pred inv10_correct_4[] {
all c:Class, s:Student | some g:Group | s->g in c.Groups
}

pred inv10_correct_5[] {
all x:Class, p:Student| some g:Group | x->p->g in Groups
}

pred inv10_correct_6[] {
all c : Class, t : Student | some g : Group | c -> t -> g in Groups
}

pred inv10_correct_7[] {
all s : Student, c: Class | some g : Group | c->s->g in Groups
}

pred inv10_correct_8[] {
all x : Class , y : Student | some g : Group | x->y->g in Groups
}

