module alloy4fun_augmented_classroom_rl_inv14
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
all p1, p2 : Person, c : Class | (some g : Group | c -> p2 -> g in Groups and p1 -> c in Teaches) implies p1 -> p2 in Tutors
}

pred inv14_correct_1[] {
all s : Person, c : Class | some s.(c.Groups) implies (Teaches.c in Tutors.s )
}

pred inv14_correct_2[] {
all c : Class, p : Person | some p.(c.Groups) implies Teaches.c in Tutors.p
}

pred inv14_correct_3[] {
all c : Class, g : Group, p1, p2 : Person | {
    (p1->c in Teaches and c->p2->g in Groups) implies (p1->p2 in Tutors)  
  }
}

pred inv14_correct_4[] {
all s:Person,c:Class, g:Group  | (c->s->g in Groups => all t:Person | t->c in Teaches => t->s in Tutors)
}

pred inv14_correct_5[] {
all s :Person, c:Class | (some g:Group | c->s->g in Groups) implies  (all t:Person| t->c in Teaches implies t->s in Tutors)
}

pred inv14_correct_6[] {
all p : Person, c : Class | some p.(c.Groups) implies Teaches.c in Tutors.p
}

pred inv14_correct_7[] {
all c : Class, p : Person | p in (c.Groups).Group implies Teaches.c in Tutors.p
}

pred inv14_correct_8[] {
all x, v : Person, y : Class | (some z : Group | y->x->z in Groups) and v->y in Teaches implies v->x in Tutors
}

pred inv14_correct_9[] {
all c : Class, p : Person | some p.(c.Groups) implies Teaches.c->p in Tutors
}

pred inv14_correct_10[] {
all p1, p2 : Person, c : Class | some p2.(c.Groups) and c in p1.Teaches implies p1 -> p2 in Tutors
}

pred inv14_correct_11[] {
all p1, p2 : Person, c : Class | some p2.(c.Groups) and c in p1.Teaches implies p2 in p1.Tutors
}

pred inv14_correct_12[] {
all c: Class | Teaches.c->c.Groups.Group in Tutors
}

pred inv14_correct_13[] {
all c : Class, s : c.Groups.Group | all t : Teaches.c | t->s in Tutors
}

pred inv14_correct_14[] {
all c: Class, s:Person| s in c.Groups.Group implies Teaches.c in Tutors.s
}

pred inv14_correct_15[] {
all s,t : Person, c : Class | some s.(c.Groups) and some (t<:Teaches).c implies some (t<:Tutors).s
}

pred inv14_correct_16[] {
all c : Class, s : c.Groups.Group | (all t : Teaches.c | s in t.Tutors)
}

pred inv14_correct_17[] {
all p:Person, c:Class| (some g :Group |c->p->g in Groups) implies  all t:Person| t->c in Teaches 
														   implies t->p in Tutors
}

