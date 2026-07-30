module alloy4fun_augmented_classroom_rl_inv10
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
all c:Class |all s:Student | some (s <: c.Groups)
}

pred inv10_correct_1[] {
all s:Student,c:Class | some s.(c.Groups)
}

pred inv10_correct_2[] {
all c : Class | ((c . Groups) . Group) & Student = Student
}

pred inv10_correct_3[] {
all c : Class | all s : Student | some s.(c.Groups)
}

pred inv10_correct_4[] {
all c : Class | Student in c.Groups.Group
}

pred inv10_correct_5[] {
all c:Class |all s:Student|some g:Group |c->s->g in Groups
}

pred inv10_correct_6[] {
all c : Class, s : Student | some g : Group | c -> s -> g in Groups
}

pred inv10_correct_7[] {
Class->Student in Groups.Group
}

pred inv10_correct_8[] {
all c:Class, s:Student | some g:Group | (s->g) in c.Groups
}

pred inv10_correct_9[] {
all c:Class,s:Student | some s <: c.Groups
}

pred inv10_correct_10[] {
all c: Class | all s: Student | some g: Group | s in c.Groups.g
}

pred inv10_correct_11[] {
all s: Student, c: Class | some g : Group | c->s->g in Groups
}

pred inv10_correct_12[] {
all c : Class | all s: Student | some (s.(c.Groups))
  
  all s : Student | all c : Class | some (s.(c.Groups))
}

pred inv10_correct_13[] {
all x:Class, p:Student| some g:Group | x->p->g in Groups
}

pred inv10_correct_14[] {
all c: Class, s : Student | s in c.Groups.Group
}

pred inv10_correct_15[] {
all c:Class | all s:Student | some g:Group | s->g in c.Groups
}

pred inv10_correct_16[] {
all c : Class, s : Student | some s->Group & c.Groups
}

