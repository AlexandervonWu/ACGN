module alloy4fun_augmented_classroom_rl_inv11
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
all c : Class | (some c.Groups implies some (Teaches.c & Teacher))
}

pred inv11_correct_1[] {
all c: Class | some c.Groups implies some c.~Teaches & Teacher
}

pred inv11_correct_2[] {
all c: Class | some c.Groups => some Teacher <: Teaches.c
}

pred inv11_correct_3[] {
all c : Class | some c <: Groups implies some Teacher & Teaches.c
}

pred inv11_correct_4[] {
all c : Class | no (Teacher <: Teaches).c => no c.Groups
}

pred inv11_correct_5[] {
all c:Class, s:Person, g:Group | c->s->g in Groups implies (some t:Teacher | t->c in Teaches)
}

pred inv11_correct_6[] {
all c : Class | some c.Groups => (some t : Teacher | t->c in Teaches)
}

pred inv11_correct_7[] {
all c : Class | (some c.Groups) implies some (Teacher<:Teaches).c
}

pred inv11_correct_8[] {
all c: Class, g: Group, p: Person |
  		(c->p->g in Groups) => (some t : Teacher | t->c in Teaches)
}

pred inv11_correct_9[] {
all c: Class | no (c.Groups) or some Teacher & Teaches.c
}

pred inv11_correct_10[] {
all c: Class | no Person.(c.Groups) or some (Teacher & Teaches.c)
}

pred inv11_correct_11[] {
all c:Class | some Person.(c.Groups) implies some t:Teacher | t->c in Teaches
}

pred inv11_correct_12[] {
Groups.Group.Person in Teacher.Teaches
}

pred inv11_correct_13[] {
all c: Class | some Person.(c.Groups) implies some t:Teacher | t in Teaches.c
}

pred inv11_correct_14[] {
all c : Class | (some p : Person, g : Group | c -> p -> g in Groups) implies (some t : Teacher | t -> c in Teaches)
}

pred inv11_correct_15[] {
all c: Class | some c.Groups implies c in Teacher.Teaches
}

pred inv11_correct_16[] {
no (Class - Teacher.Teaches).Groups
}

pred inv11_correct_17[] {
all c: Class | some Person.(c.Groups) implies some (Teacher & Teaches.c)
}

pred inv11_correct_18[] {
all c: Class | some c.Groups implies some Teaches.c :> Teacher
}

pred inv11_correct_19[] {
all x : Class | (some y : Person, z : Group | x->y->z in Groups) implies some v : Teacher | v->x in Teaches
}

pred inv11_correct_20[] {
all c : Class { some c.Groups implies some t : Teacher | c in t.Teaches }
}

pred inv11_correct_21[] {
all c : Class | no (c.~Teaches :> Teacher) implies no c.Groups
}

pred inv11_correct_22[] {
all c:Class | (some g:Group |some p:Person | c->p->g in Groups)   implies some (Teaches.c & Teacher)
}

pred inv11_correct_23[] {
all c: Class | some c.Groups implies (some t: Teacher | t in Teaches.c)
}

