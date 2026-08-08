module alloy4fun_augmented_coursesNew_inv11
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
all c : Course | ( all g : Grade , p : Person | p->g in c.grades implies p in enrolled.c )
}

pred inv11_correct_1[] {
all p : Person | all g : Grade | all c : Course | p->g in c.grades implies c in p.enrolled
}

pred inv11_correct_2[] {
all c: Course | (all p: Person, g: Grade | p->g in c.grades implies c in p.enrolled)
}

pred inv11_correct_3[] {
all c : Course | all p : Person | all g : Grade | p->g in c.grades implies c in p.enrolled
}

pred inv11_correct_4[] {
all p: Person, g:Grade, c:Course | p->g in c.grades implies c in p.enrolled
}

pred inv11_correct_5[] {
all p : Person, c : Course | some p.(c.grades) implies c in p.enrolled
}

pred inv11_correct_6[] {
all x : Person | all y : Course | some y.grades[x] implies y in x.enrolled
}

pred inv11_correct_7[] {
all c:Course | c.grades in enrolled.c->Grade
}

pred inv11_correct_8[] {
all c:Course, g:Grade | c.grades.g in enrolled.c
}

pred inv11_correct_9[] {
~(grades.Grade) in enrolled
}

pred inv11_correct_10[] {
all c : Course, p : Person, g : Grade | p->g in c.grades implies c in p.enrolled
}

pred inv11_correct_11[] {
all x : Person | all y : Course | some x.(y.grades) implies x in enrolled.y
}

pred inv11_correct_12[] {
all g : Grade | all c : Course | all x : Person | x -> g in c.grades implies c in x.enrolled
}

pred inv11_correct_13[] {
all c: Course | all p: (c.grades).Grade | c in p.enrolled
}

pred inv11_correct_14[] {
all p: Person | all c: Course, g: Grade | p->g in c.grades implies c in p.enrolled
}

pred inv11_correct_15[] {
all c : Course , p : c.grades.Grade | p in enrolled.c
}

pred inv11_correct_16[] {
all p : Person | all g: Grade, c: Course | p->g in c.grades implies c in p.enrolled
}

pred inv11_correct_17[] {
all c : Course, g : Grade, p : Person | p->g in c.grades implies one (c & p.enrolled)
}

pred inv11_correct_18[] {
all x:Person, c:Course, g:Grade| c->x->g in grades implies x-> c in enrolled
}

