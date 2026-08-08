module alloy4fun_augmented_coursesOld_inv8
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

pred inv8_oracle[] {
(all p : Person | no p.teaches & p.enrolled)
}

pred inv8_correct_0[] {
all p: Person, c: Course | p->c in teaches implies p->c not in enrolled
}

pred inv8_correct_1[] {
all p:Person, c:Course | p -> c in enrolled implies p -> c not in teaches
}

pred inv8_correct_2[] {
all p1: Person | all c: Course| p1->c in enrolled implies p1->c not in teaches
}

pred inv8_correct_3[] {
no teaches.~enrolled & iden
}

pred inv8_correct_4[] {
all c : Course | no teaches.c & enrolled.c
}

pred inv8_correct_5[] {
all p1 : Person | all c1 : Course | p1->c1 in teaches implies p1->c1 not in enrolled
}

pred inv8_correct_6[] {
no teaches  & enrolled
}

pred inv8_correct_7[] {
all c: Course, p: Person | c in p.teaches => c not in p.enrolled
}

pred inv8_correct_8[] {
all p:Person,c:Course | p->c not in teaches or p->c not in enrolled
}

pred inv8_correct_9[] {
all p:Person | no c:Course | c in p.teaches and c in p.enrolled
}

pred inv8_correct_10[] {
all cours: Course | cours not in cours.~teaches.enrolled
}

pred inv8_correct_11[] {
no p: Person | p in p.teaches.~enrolled
}

pred inv8_correct_12[] {
all p : Person , c: Course | no p.teaches & p.enrolled
}

pred inv8_correct_13[] {
all p : Person | all c : Course | c in p.teaches implies c not in p.enrolled
}

pred inv8_correct_14[] {
all p:Person, c: Course | p in teaches.c implies p not in enrolled.c
}

pred inv8_correct_15[] {
no iden & teaches.~enrolled
}

pred inv8_correct_16[] {
all p:Person,c:Course | c in p.teaches implies c not in p.enrolled
}

pred inv8_correct_17[] {
all p:Person | p.teaches & p.enrolled = none
}

