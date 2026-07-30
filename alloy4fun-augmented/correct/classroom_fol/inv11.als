module alloy4fun_augmented_classroom_fol_inv11
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv11_oracle[] {
all c:Class | some c.Groups implies some Teacher&Teaches.c
}

pred inv11_correct_0[] {
all c : Class | (some s : Person | some g : Group | c->s->g in Groups) => some t : Teacher | t->c in Teaches
}

pred inv11_correct_1[] {
all c : Class | (some s : Person, g : Group | c -> s -> g in Groups) => some t : Teacher | t -> c in Teaches
}

pred inv11_correct_2[] {
all c:Class | some c.Groups implies (some t:Teacher | t->c in Teaches)
}

pred inv11_correct_3[] {
all c:Class | (some g:Group | some p:Person | c->(p->g) in Groups) implies (some t:Teacher | t->c in Teaches)
}

pred inv11_correct_4[] {
all c : Class | (some g : Group, p : Person | c->p->g in Groups) implies (some t : Teacher | t->c in Teaches)
}

pred inv11_correct_5[] {
all c : Class, g : Group, p : Person | (c->p->g in Groups) => (some t : Teacher | t->c in Teaches)
}

pred inv11_correct_6[] {
all c : Class | (some p : Person, g : Group | c -> p -> g in Groups) implies 
	(some t : Teacher | t -> c in Teaches)
}

pred inv11_correct_7[] {
all c : Class | (all t : Teacher | (t -> c not in Teaches)) implies (all p : Person, g : Group | c -> p -> g not in Groups)
}

pred inv11_correct_8[] {
all c : Class, p : Person, g : Group | c->p->g in Groups implies (some t : Teacher | t->c in Teaches)
}

pred inv11_correct_9[] {
all c:Class | some c.Groups.Group implies some t:Teacher | t->c in Teaches
}

pred inv11_correct_10[] {
all c:Class,g:Group | some c.Groups.g implies some t:Teacher | t->c in Teaches
}

pred inv11_correct_11[] {
all c : Class | (some g : Group, s : Person | c -> s -> g in Groups) implies some t : Teacher | t -> c in Teaches
}

pred inv11_correct_12[] {
all x : Class | (some p: Person, g : Group | x->p->g in Groups) implies (some t : Teacher | t->x in Teaches)
}

pred inv11_correct_13[] {
all c:Class | some Person.(c.Groups) implies some t:Teacher | t->c in Teaches
}

pred inv11_correct_14[] {
all x : Class | (some y : Person, z : Group | x->y->z in Groups) implies some v : Teacher | v->x in Teaches
}

pred inv11_correct_15[] {
all c : Class, s : Person, g : Group | some t : Person | c->s->g in Groups implies t->c in Teaches and t in Teacher
}

pred inv11_correct_16[] {
all c : Class | (some c.Groups) implies (some (Teacher & c.~Teaches))
}

pred inv11_correct_17[] {
all c : Class | all g : Group, p : Person | c->p->g in Groups implies some t : Teacher | t->c in Teaches
}

