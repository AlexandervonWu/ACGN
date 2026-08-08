module alloy4fun_augmented_coursesNew_inv10
sig Person {
	teaches : set Course,
	enrolled : set Course,
	projects : set Project
}

sig Professor,Student in Person {}

sig Course {
	projects : set Project,
	grades : Person -> Grade
}

sig Project {}

sig Grade {}

pred inv10_oracle[] {
Course.grades.Grade in Student
}

pred inv10_correct_0[] {
all p:Person | p in Course.grades.Grade implies p in Student
}

pred inv10_correct_1[] {
all p : Person | all g : Grade | p->g in Course.grades implies p in Student
}

pred inv10_correct_2[] {
all g : Grade | all c : Course | all x : Person | x -> g in c.grades implies x in Student
}

pred inv10_correct_3[] {
all c : Course | ( all g : Grade, p : Person | p->g in c.grades implies p in Student )
}

pred inv10_correct_4[] {
all c : Course | all p : Person, g : Grade | p -> g in c.grades implies p in Student
}

pred inv10_correct_5[] {
all x:Person, g:Grade, c:Course| c->x->g in grades implies x in Student
}

pred inv10_correct_6[] {
all x: Person | all y:Course | all z:Grade | x->z in y.grades implies x in Student
}

pred inv10_correct_7[] {
no Course.grades & (Person-Student)->Grade
}

pred inv10_correct_8[] {
all x : Person | all y : Course | some y.grades[x] implies x in Student
}

pred inv10_correct_9[] {
all p:(Person-Student) | p not in Course.grades.Grade
}

pred inv10_correct_10[] {
all p:Person, c:Course, g:Grade | c->p->g in grades implies p in Student
}

pred inv10_correct_11[] {
all p:Person, g:Grade, c:Course| c->p->g in grades implies p in Student
}

pred inv10_correct_12[] {
all x:Person, c:Course, g:Grade| c->x->g in grades implies x in Student
}

pred inv10_correct_13[] {
all p: Course.grades.Grade | p in Student
}

pred inv10_correct_14[] {
all p : Person - Student, c : Course, g : Grade | p->g not in c.grades
}

pred inv10_correct_15[] {
all y:Course, g:Grade | (y.grades).g in Student
}

pred inv10_correct_16[] {
all p : Person, c : Course | some p.(c.grades) implies p in Student
}

pred inv10_correct_17[] {
grades in Course->Student-> Grade
}

pred inv10_correct_18[] {
all x: Person, y: Course | some x.(y.grades) implies x in Student
}

pred inv10_correct_19[] {
all p : Person, g : Grade | g in Course.grades[p] implies p in Student
}

pred inv10_correct_20[] {
all x :Person | all c : Course| all g: Grade | x->g in c.grades implies x in Student
}

pred inv10_correct_21[] {
all c : Course, st : Person, g : Grade | (st->g in c.grades) implies (st in Student)
}

pred inv10_correct_22[] {
all c:Course , p:Person , g:Grade | p->g in c.grades implies p in Student
}

pred inv10_correct_23[] {
all p:Person ,c:Course | #p->Grade&c.grades>0 implies p in Student
}

pred inv10_correct_24[] {
Course.grades in Student -> Grade
}

pred inv10_correct_25[] {
all c : Course | all p : Person | all g : Grade | p->g in c.grades implies p in Student
}

pred inv10_correct_26[] {
all c : Course | all g : Grade | all p : Person | p->g in c.grades => p in Student
}

pred inv10_correct_27[] {
all p:Person | all g:Grade | all c1:Course | (c1->p->g in grades) implies (p in Student)
}

pred inv10_correct_28[] {
all c:Course | c.grades in Student->Grade
}

pred inv10_correct_29[] {
all u:Person, c:Course, g:Grade| c->u->g in grades implies u in Student
}

pred inv10_correct_30[] {
all c:Course, g:Grade | (c.grades).g in Student
}

pred inv10_correct_31[] {
all x:Person | all z:Course | all y:Grade | x->y in z.grades implies x in Student
}

pred inv10_correct_32[] {
all x: Person| all c: Course| all g: Grade| x in c.grades.g implies x in Student
}

pred inv10_correct_33[] {
all c:Course, s:Person-Student | no c.grades[s]
}

pred inv10_correct_34[] {
all c:Course, p:Person, g:Grade | c->p->g in grades implies p in Student
}

pred inv10_correct_35[] {
all p: Person | all c: Course, g: Grade | p->g in c.grades implies p in Student
}

pred inv10_correct_36[] {
all p1: Person | all c : Course | all g : Grade | p1->g in c.grades implies p1 in Student
}

pred inv10_correct_37[] {
all p:Person, c:Course, g:Grade | p->g in c.grades implies p in Student
}

pred inv10_correct_38[] {
all p1 : Person, c : Course |some p1.(c.grades) implies p1 in Student
}

pred inv10_correct_39[] {
all c:Course |(all s:Person,g:Grade | s->g  in c.grades implies s in Student)
}

pred inv10_correct_40[] {
all p:Person | all g:Grade, c:Course | p->g in c.grades implies p in Student
}

pred inv10_correct_41[] {
all c : Course, p : Person, g : Grade | g in c.grades[p] implies p in Student
}

pred inv10_correct_42[] {
all p: Person, g: Grade | p->g in Course.grades implies p in Student
}

pred inv10_correct_43[] {
all p1 : Person | all c1 : Course | all g1 : Grade|
  	(c1->p1->g1 in grades) implies (p1 in Student)
}

pred inv10_correct_44[] {
all c : Course | c.grades.Grade in Student
}

pred inv10_correct_45[] {
all p:Person | all c: Course | all g: Grade | c->p->g in grades => p in Student
}

pred inv10_correct_46[] {
all c : Course | all p : Person-Student| no p.(c.grades)
}

pred inv10_correct_47[] {
all p : Person, g : Grade , c : Course | some p.(c.grades) implies p in Student
}

pred inv10_correct_48[] {
all c : Course | (all p : Person, g : Grade | c->p->g in grades implies p in Student)
}

pred inv10_correct_49[] {
all p : Person , g : Grade, c : Course | p->g in c.grades implies p in Student
}

pred inv10_correct_50[] {
all x: Course | all p: x.grades.Grade | p in Student
}

pred inv10_correct_51[] {
all p : Person | all g : Grade | all c : Course | p->g in c.grades implies p in Student
}

pred inv10_correct_52[] {
all p: Person - Student | all c: Course | no p.(c.grades)
}

pred inv10_correct_53[] {
all p : Person, c: Course, g : Grade | g in p.(c.grades) implies p in Student
}

pred inv10_correct_54[] {
no (Person - Student).(Course.grades)
}

