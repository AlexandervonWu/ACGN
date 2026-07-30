module alloy4fun_augmented_classroom_fol_inv5
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv5_oracle[] {
some Teacher.Teaches
}

pred inv5_correct_0[] {
some c : Class | some t : Teacher | t->c in Teaches
}

pred inv5_correct_1[] {
some x : Teacher, y : Class  | x->y in Teaches
}

pred inv5_correct_2[] {
some t : Teacher, c : Class | t->c in Teaches
}

pred inv5_correct_3[] {
some c : Class, t : Teacher | t->c in Teaches
}

pred inv5_correct_4[] {
some t : Teacher | some c : Class | t->c in Teaches
}

pred inv5_correct_5[] {
some c : Class |  c in Teacher.Teaches
}

pred inv5_correct_6[] {
some p : Person | p in Teacher && some c : Class | p -> c in Teaches
}

pred inv5_correct_7[] {
some p : Person, c : Class | p in Teacher and p -> c in Teaches
}

pred inv5_correct_8[] {
some c : Class, p : Person | p -> c in Teaches and p in Teacher
}

pred inv5_correct_9[] {
some t:Person| t in Teacher and some c: Class | t->c in Teaches
}

pred inv5_correct_10[] {
some c : Class, p : Teacher | p -> c in Teaches
}

pred inv5_correct_11[] {
some p : Person | some t : Teacher, c : Class {
    t->c in Teaches
  }
}

pred inv5_correct_12[] {
some c:Class, p:Person | p in Teacher and c in p.Teaches
}

pred inv5_correct_13[] {
some c:Class, t:Teacher | c in t.Teaches
}

pred inv5_correct_14[] {
some p:Teacher | some c:Class | p->c in Teaches
}

pred inv5_correct_15[] {
some c : Class | (some t : Teacher | teaches_class[t,c])
}

pred inv5_correct_16[] {
some x: Class, t:Teacher| t->x in Teaches
}

pred inv5_correct_17[] {
some x: Teacher | some c: Class | x->c in Teaches
}

pred inv5_correct_18[] {
some c : Class | some x : Teacher | x->c in Teaches
}

pred inv5_correct_19[] {
some p:Teacher,c:Class | p->c in Teaches
}

pred inv5_correct_20[] {
some c : Class | some t : Teacher | c in t.Teaches
}

