module alloy4fun_augmented_coursesOld_inv11
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

pred inv11_oracle[] {
all c : Course | c.grades.Grade in enrolled.c
}

pred inv11_correct_0[] {
all p,c,g : univ | p in Person and c in Course and g in Grade and c->p->g in grades implies p->c in enrolled
}

pred inv11_correct_1[] {
all p:Person,c:Course,g:Grade | (p->g in c.grades) implies (c in p.enrolled)
}

pred inv11_correct_2[] {
all c: Course, p:Person, g:Grade | c->p->g in grades => p->c in enrolled
}

pred inv11_correct_3[] {
all c : Course, p:Person | p in c.grades.Grade implies p in enrolled.c
}

pred inv11_correct_4[] {
all c : Course, s : c.grades.Grade | c in s.enrolled
}

pred inv11_correct_5[] {
grades.Grade in ~enrolled
}

pred inv11_correct_6[] {
all c : Course | c.grades.Grade in (c.~enrolled)
}

pred inv11_correct_7[] {
~(grades.Grade) in enrolled
}

pred inv11_correct_8[] {
all p:Person,c:Course,g:Grade | (g in p.(c.grades)) implies (c in p.enrolled)
}

pred inv11_correct_9[] {
all c: Course | all p: Person | all g: Grade | c->p->g in grades implies p->c in enrolled
}

pred inv11_correct_10[] {
all p : Person, c : Course | c not in p.enrolled implies no ~(c.grades).p
}

pred inv11_correct_11[] {
all p : Person, c : Course | c not in p.enrolled implies p not in c.grades.Grade
}

pred inv11_correct_12[] {
all c:Course, p:Person, g:Grade | c->p->g in grades => c in p.enrolled
}

pred inv11_correct_13[] {
all p: Person, c: Course | p in (c.grades.Grade) implies c in p.enrolled
}

pred inv11_correct_14[] {
all p : Person | p not in (Course-(p.enrolled)).grades.Grade
}

pred inv11_correct_15[] {
all p: Person, c: Course, g: Grade | c->p->g in grades implies p in enrolled.c
}

pred inv11_correct_16[] {
all p:Person,c:Course,g:Grade | (c->p->g in grades) implies (p->c in enrolled)
}

pred inv11_correct_17[] {
all p: Person | all g: Grade | all c: Course | c->p->g in grades implies p->c in enrolled
}

pred inv11_correct_18[] {
all c:Course,p:Person,g:Grade | c->p->g in grades implies c->p in ~enrolled
}

pred inv11_correct_19[] {
all p : Person | all c : Course | p in c.grades.Grade implies c in p.enrolled
}

pred inv11_correct_20[] {
all c:Course | c.(grades.Grade) in enrolled.c
}

pred inv11_correct_21[] {
all p1 : Person | grades.Grade.p1 in p1.enrolled
}

pred inv11_correct_22[] {
all p: Person, c: Course, g: Grade | p in c.grades.g implies p in enrolled.c
}

pred inv11_correct_23[] {
all p:Person,c:Course,g:Grade | (c->p->g in grades) implies (c in p.enrolled)
}

