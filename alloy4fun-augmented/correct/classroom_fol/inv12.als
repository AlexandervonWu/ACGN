module alloy4fun_augmented_classroom_fol_inv12
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv12_oracle[] {
all x:Teacher | some x.Teaches.Groups
}

pred inv12_correct_0[] {
all t:Teacher | some c:Class,g:Group,p:Person | c->p->g in Groups and t->c in Teaches
}

pred inv12_correct_1[] {
all t: Teacher | some c:Class | t->c in Teaches and some g:Group, p:Person | c->p->g in Groups
}

pred inv12_correct_2[] {
all t:Teacher | some c:Class | t->c in Teaches and (some g:Group | some p:Person | c->(p->g) in Groups)
}

pred inv12_correct_3[] {
all t:Teacher | some t.Teaches.Groups
}

pred inv12_correct_4[] {
all t:Teacher | some g:Group, s:Person, c:Class | c->s->g in Groups and t->c in Teaches
}

pred inv12_correct_5[] {
all t : Teacher | some p : Person, c : Class, g : Group | t->c in Teaches and c->p->g in Groups
}

pred inv12_correct_6[] {
all t: Teacher | some c:Class,g:Group,p:Person | t->c in Teaches and c->p->g in Groups
}

pred inv12_correct_7[] {
all t:Teacher | some g:Group, c: Class, p: Person |c->p->g in Groups and t->c in Teaches
}

pred inv12_correct_8[] {
all t : Teacher | some c : Class | t->c in Teaches and (some g : Group, s : Person | c->s->g in Groups)
}

pred inv12_correct_9[] {
all t:Teacher | some c:Class,p:Person,g:Group | c->p->g in Groups and t->c in Teaches
}

pred inv12_correct_10[] {
all t : Teacher | some g : Group, c : Class, p : Person | t->c in Teaches and c->p->g in Groups
}

pred inv12_correct_11[] {
all t:Teacher | some c:Class | t->c in Teaches and (some p:Person,g:Group | c->p->g in Groups)
}

pred inv12_correct_12[] {
all x : Teacher | some y : Class, z : Group, v : Person | x->y in Teaches and y->v->z in Groups
}

pred inv12_correct_13[] {
all t : Teacher | some c : Class | (some s : Person | some g : Group | c->s->g in Groups) and t->c in Teaches
}

pred inv12_correct_14[] {
all t : Teacher | some c : Class, p : Person, g : Group  | t->c in Teaches and c->p->g in Groups
}

pred inv12_correct_15[] {
all t:Teacher | some p:Person,g:Group,c:Class | c->p->g in Groups and t->c in Teaches
}

pred inv12_correct_16[] {
all t:Teacher | some g:Group, p:Person, c:Class | c->p->g in Groups and t->c in Teaches
}

