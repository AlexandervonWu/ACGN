module alloy4fun_augmented_classroom_rl_inv12
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
all t : Teacher | some t.Teaches.Groups
}

pred inv12_correct_1[] {
all t: Teacher | some c:Class | t->c in Teaches and some g:Group, p:Person | c->p->g in Groups
}

pred inv12_correct_2[] {
all t : Teacher | some t<:(Teaches.Groups)
}

pred inv12_correct_3[] {
all t : Teacher | some c : t.Teaches | some c.Groups
}

pred inv12_correct_4[] {
all t : Teacher | some t . Teaches <: (Groups)
}

pred inv12_correct_5[] {
Teacher in Teaches.(Groups.Group.Person)
}

pred inv12_correct_6[] {
all t:Teacher | some p:Person, c:Class, g:Group |  t->c in Teaches and c->p->g in Groups
}

pred inv12_correct_7[] {
all t: Teacher | some c:Class | t->c in Teaches and some c.Groups
}

pred inv12_correct_8[] {
all t : Teacher | some p : Person, g : Group | some (t.Teaches).Groups
}

pred inv12_correct_9[] {
Teacher in Teaches.Groups.Group.Person
}

pred inv12_correct_10[] {
all t:Teacher | some p:Person, c:Class, g:Group |  c->p->g in Groups and t->c in Teaches
}

pred inv12_correct_11[] {
Teaches.(Groups.Group.Person) & Teacher = Teacher
}

pred inv12_correct_12[] {
Teaches.Groups.Group.Person & Teacher = Teacher
}

pred inv12_correct_13[] {
all t : Teacher | some (t<:Teaches).Groups
}

