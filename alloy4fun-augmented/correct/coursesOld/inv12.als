module alloy4fun_augmented_coursesOld_inv12
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

pred inv12_oracle[] {
all p : Person, c : Course | lone p.(c.grades)
}

pred inv12_correct_0[] {
grades in Course set -> set Person -> lone Grade
}

pred inv12_correct_1[] {
all c: Course, p:Person, g1, g2:Grade | c->p->g1 in grades and c->p->g2 in grades => g1 = g2
}

pred inv12_correct_2[] {
all c : Course | all s : Person | lone (s.(c.grades))
}

pred inv12_correct_3[] {
all p: Person, c: Course | lone g: Grade | p in c.grades.g
}

pred inv12_correct_4[] {
all c:Course, p:Person | lone g:Grade | c->p->g in grades
}

pred inv12_correct_5[] {
all p,c,g1,g2 : univ | p in Person and c in Course and g1 in Grade and g2 in Grade and c->p->g1 in grades and c->p->g2 in grades implies g1=g2
}

pred inv12_correct_6[] {
all p : Person | all c : Course | all g1,g2 : Grade | (p->g1 + p->g2) in c.grades implies g1=g2
}

pred inv12_correct_7[] {
all g1,g2:Grade | (some c:Course,p:Person | c->p->g1 in grades and c->p->g2 in grades) implies g1=g2
}

pred inv12_correct_8[] {
all c : Course | c.grades in Person -> lone Grade
}

