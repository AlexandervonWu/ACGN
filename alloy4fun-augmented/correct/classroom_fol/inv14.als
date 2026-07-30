module alloy4fun_augmented_classroom_fol_inv14
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv14_oracle[] {
all c:Class,p:Person | p in (c.Groups).Group implies Teaches.c -> p in Tutors
}

pred inv14_correct_0[] {
all p, q : Person, c : Class | (some g : Group | c->p->g in Groups) and q->c in Teaches implies q->p in Tutors
}

pred inv14_correct_1[] {
all s,t : Person | all c : Class | all g : Group | (c->(s->g) in Groups and t->c in Teaches) implies t->s in Tutors
}

pred inv14_correct_2[] {
all p : Person, c : Class | (some g : Group | c->p->g in Groups) implies (all t : Person | t->c in Teaches implies t->p in Tutors)
}

pred inv14_correct_3[] {
all c : Class, g : Group, p1, p2 : Person | (p1->c in Teaches and c->p2->g in Groups) implies (p1->p2 in Tutors)
}

pred inv14_correct_4[] {
all s:Person,c:Class | (some g:Group | c->s->g in Groups) implies (all t:Person | t->c in Teaches implies t->s in Tutors)
}

pred inv14_correct_5[] {
all p1, p2 : Person, c : Class | (some g : Group | c -> p2 -> g in Groups and 
		p1 -> c in Teaches) implies p1 -> p2 in Tutors
}

pred inv14_correct_6[] {
all s : Person, c : Class, t : Person | (some g : Group | c->s->g in Groups) and t->c in Teaches implies t->s in Tutors
}

pred inv14_correct_7[] {
all s : Person, c : Class, t : Person, g : Group | (c -> s -> g in Groups) and t -> c in Teaches implies t -> s in Tutors
}

pred inv14_correct_8[] {
all s: Person, c: Class, t: Person, g: Group | c->s->g in Groups => (t->c in Teaches => t->s in Tutors)
}

pred inv14_correct_9[] {
all s, t : Person, c : Class | (some g : Group | c->s->g in Groups) and t->c in Teaches implies t->s in Tutors
}

pred inv14_correct_10[] {
all s : Person, c : Class, g : Group, t : Person | c -> s -> g in Groups and t -> c in Teaches implies t -> s in Tutors
}

pred inv14_correct_11[] {
all s:Person,c:Class,g:Group | (c->s->g in Groups => all t:Person | t->c in Teaches => t->s in Tutors)
}

pred inv14_correct_12[] {
all p1, p2 : Person, c : Class, g : Group | (c->p1->g in Groups and p2->c in Teaches) implies p2->p1 in Tutors
}

pred inv14_correct_13[] {
all s : Person, g : Group, c : Class | (c->s->g in Groups) => (all t : Person | (t->c in Teaches) => (t->s in Tutors))
}

pred inv14_correct_14[] {
all p1, p2 : Person, c : Class | (some g : Group | c->p1->g in Groups) implies p2->c in Teaches implies p2->p1 in Tutors
}

pred inv14_correct_15[] {
all p1, p2 : Person, c : Class | ((some g : Group | c -> p2 -> g in Groups) and 
		p1 -> c in Teaches) implies p1 -> p2 in Tutors
}

pred inv14_correct_16[] {
all c:Class,s:Person | (some g:Group | c->s->g in Groups) implies (all t:Person | t->c in Teaches implies t->s in Tutors)
}

pred inv14_correct_17[] {
all s : Person | all t : Person | all c : Class | all g : Group | c->s->g in Groups and t->c in Teaches => t->s in Tutors
}

pred inv14_correct_18[] {
all p : Person, c : Class | some p.(c.Groups) implies Teaches.c in Tutors.p
}

pred inv14_correct_19[] {
all c : Class , s, t : Person | all g : Group | 
    ((c->s->g in Groups) and (t->c in Teaches)) implies t->s in Tutors
}

pred inv14_correct_20[] {
all s,t:Person, c:Class, g:Group | c->s->g in Groups and t->c in Teaches => t->s in Tutors
}

pred inv14_correct_21[] {
all x, v : Person, y : Class | (some z : Group | y->x->z in Groups) and v->y in Teaches implies v->x in Tutors
}

pred inv14_correct_22[] {
all ps : Person, t :  Person | all c : Class, g : Group | c->ps->g in Groups and t->c in Teaches implies t->ps in Tutors
}

pred inv14_correct_23[] {
all s:Person, t:Person, c:Class, g:Group | c->s->g in Groups and t->c in Teaches => t->s in Tutors
}

