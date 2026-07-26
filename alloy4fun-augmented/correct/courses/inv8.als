module alloy4fun_augmented_courses_inv8
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
all p:Person, c:Course | (c in p.teaches) implies (c not in p.enrolled)
}

pred inv8_correct_1[] {
all x:Person, y : Course| x->y in teaches implies x->y not in enrolled
}

pred inv8_correct_2[] {
all x:Person | no (x.enrolled & x.teaches)
}

pred inv8_correct_3[] {
all p: Person, c: Course | p in c.~teaches => p not in c.~enrolled
}

pred inv8_correct_4[] {
all p: Person | all c: Course | c in p.teaches => c not in p.enrolled
}

pred inv8_correct_5[] {
all c : Course | no teaches.c&enrolled.c
}

pred inv8_correct_6[] {
all c : Course, t : teaches.c | t not in enrolled.c
}

pred inv8_correct_7[] {
no teaches & enrolled
}

pred inv8_correct_8[] {
all s1 : Person | all c1 : Course | c1 in s1.teaches implies c1 not in s1.enrolled
}

pred inv8_correct_9[] {
all x : Person | all y : Course | y in x.enrolled implies y not in x.teaches
}

pred inv8_correct_10[] {
all t : Person | no t.teaches & t.enrolled
}

pred inv8_correct_11[] {
all x:Person, c:Course| x->c in teaches implies x->c not in enrolled
}

