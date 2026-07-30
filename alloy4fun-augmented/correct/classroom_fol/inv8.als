module alloy4fun_augmented_classroom_fol_inv8
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv8_oracle[] {
all t:Teacher | lone t.Teaches
}

pred inv8_correct_0[] {
all t : Teacher | all c1,c2 : Class | t->c1 in Teaches and t->c2 in Teaches implies c1=c2
}

pred inv8_correct_1[] {
all x,y:Class, t:Teacher | t->x in Teaches and t->y in Teaches implies x=y
}

pred inv8_correct_2[] {
all t : Teacher, c1, c2 : Class | (t->c1 in Teaches) and (t->c2 in Teaches) => (c1 = c2)
}

pred inv8_correct_3[] {
all p:Teacher, c1, c2:Class | p->c1 in Teaches and p->c2 in Teaches => c1=c2
}

pred inv8_correct_4[] {
all t : Teacher | lone c : Class | t->c in Teaches
}

pred inv8_correct_5[] {
all c1:Class,c2:Class,t:Teacher | (t->c1 in Teaches and t->c2 in Teaches) implies c1 = c2
}

pred inv8_correct_6[] {
all x: Teacher, y,z: Class | x->y in Teaches and x->z in Teaches implies y=z
}

pred inv8_correct_7[] {
all x : Teacher, y, t : Class | x -> y in Teaches and x -> t in Teaches implies y = t
}

pred inv8_correct_8[] {
all t : Teacher | all x,y : Class | t->x in Teaches and t->y in Teaches implies x=y
}

pred inv8_correct_9[] {
~(Teacher<:Teaches).(Teacher<:Teaches) in iden
}

pred inv8_correct_10[] {
all t:Teacher,c1,c2:Class | c1 in t.Teaches and c2 in t.Teaches implies c1=c2
}

pred inv8_correct_11[] {
all t : Teacher, c,d:Class | t->c in Teaches and t->d in Teaches implies c=d
}

pred inv8_correct_12[] {
(all t : Teacher | all c,u : Class | (t->c in Teaches and t->u in Teaches) implies c=u)
}

pred inv8_correct_13[] {
all t : Teacher | #(t.Teaches) < 2
}

pred inv8_correct_14[] {
all p:Teacher, c1, c2:Class | c1 = c2 or not (p->c1 in Teaches and p->c2 in Teaches)
}

pred inv8_correct_15[] {
all t : Teacher, x, y : Class | t->x in Teaches and t->y in Teaches implies x = y
}

pred inv8_correct_16[] {
all c1,c2 : Class | all t : Teacher | t->c1 in Teaches and t->c2 in Teaches implies c1=c2
}

pred inv8_correct_17[] {
all t : Teacher , c,u : Class | t->c in Teaches and t->u in Teaches implies c=u
}

pred inv8_correct_18[] {
all c1, c2 : Class | all p : Person | p in Teacher and (p -> c1 in Teaches && p -> c2 in Teaches) => c1 = c2
}

pred inv8_correct_19[] {
all x : Teacher | all c : Class | all d : Class | x->c in Teaches and c!=d implies x->d not in Teaches
}

pred inv8_correct_20[] {
all p : Teacher | all c1, c2 : Class | (p->c1 in Teaches and p->c2 in Teaches) => c1 = c2
}

pred inv8_correct_21[] {
all c1,c2:Class,t:Teacher | t->c1 in Teaches and t->c2 in Teaches implies c1=c2
}

pred inv8_correct_22[] {
all c1, c2 : Class, p : Person | p in Teacher and (p -> c1 in Teaches && p -> c2 in Teaches) => c1 = c2
}

pred inv8_correct_23[] {
all t : Teacher, c, c1 : Class | t->c in Teaches and t->c1 in Teaches implies c = c1
}

