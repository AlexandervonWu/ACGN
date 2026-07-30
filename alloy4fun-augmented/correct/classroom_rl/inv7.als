module alloy4fun_augmented_classroom_rl_inv7
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv7_oracle[] {
all c:Class | some Teacher&Teaches.c
}

pred inv7_correct_0[] {
all c : Class | c in Teacher.Teaches
}

pred inv7_correct_1[] {
Teacher.Teaches = Class
}

pred inv7_correct_2[] {
Class in Teacher.Teaches
}

pred inv7_correct_3[] {
all c:Class | some t:Teacher | t->c in Teaches
}

pred inv7_correct_4[] {
Class = Teacher.Teaches
}

pred inv7_correct_5[] {
all c : Class | some Teaches.c & Teacher
}

pred inv7_correct_6[] {
all c:Class{ some t:Teacher | t in c.~Teaches }
}

pred inv7_correct_7[] {
all c:Class | some Teacher.Teaches:>c
}

pred inv7_correct_8[] {
all c : Class | some t : Teacher | c in t.Teaches
}

pred inv7_correct_9[] {
all c : Class | (#Teaches.c & Teacher) > 0
}

pred inv7_correct_10[] {
all c:Class | some t:Teacher | t in Teaches.c
}

pred inv7_correct_11[] {
all c : Class | some x : Teacher | x->c in Teaches
}

pred inv7_correct_12[] {
all c: Class | some c.~Teaches & Teacher
}

pred inv7_correct_13[] {
all c : Class | some ( Teacher <:Teaches.c)
}

pred inv7_correct_14[] {
Class in ~Teaches.Teacher
}

pred inv7_correct_15[] {
all c : Class | some Teacher -> c & Teaches
}

pred inv7_correct_16[] {
all c : Class | some (Teaches.c & Teacher)
  
  Class in Teacher.Teaches
}

pred inv7_correct_17[] {
#(~Teaches.Teacher) >= #Class
}

pred inv7_correct_18[] {
(Class & Teacher.Teaches) = Class
}

pred inv7_correct_19[] {
all c : Class | some (Teaches.c :> Teacher)
}

