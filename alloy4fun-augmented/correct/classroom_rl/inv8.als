module alloy4fun_augmented_classroom_rl_inv8
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
(~Teaches :> Teacher) . (Teacher <: Teaches) in iden
}

pred inv8_correct_1[] {
all t : Teacher | #(t.Teaches) < 2
}

pred inv8_correct_2[] {
all x : Teacher | all c : Class | all d : Class | x->c in Teaches and c!=d implies x->d not in Teaches
}

pred inv8_correct_3[] {
~(Teacher<:Teaches).(Teacher<:Teaches) in iden
}

pred inv8_correct_4[] {
all t:Teacher { lone c:Class | c in t.Teaches}
}

pred inv8_correct_5[] {
all t:Teacher, c1,c2:Class | t->c1 in Teaches and t->c2 in Teaches implies c1=c2
}

pred inv8_correct_6[] {
Teacher <: Teaches in Teacher  -> lone Class
}

pred inv8_correct_7[] {
let c = (~Teaches) :> Teacher | c.~c in iden
}

pred inv8_correct_8[] {
all t : Teacher | lone c : Class | t->c in Teaches
}

pred inv8_correct_9[] {
all t: Teacher, c1,c2: Class | c1 in t.Teaches and c2 in t.Teaches implies c1 = c2
}

pred inv8_correct_10[] {
all t:Teacher | all c1, c2:Class | t->c1 in Teaches and t->c2 in Teaches implies c1 = c2
}

pred inv8_correct_11[] {
let Teachers = Teacher <: Teaches | ~Teachers.Teachers in iden
}

pred inv8_correct_12[] {
all t : Teacher, c, c1 : Class | (t->c + t->c1) in Teaches => c = c1
}

pred inv8_correct_13[] {
all t : Teacher | #t.Teaches >= 0 && #t.Teaches <= 1
}

