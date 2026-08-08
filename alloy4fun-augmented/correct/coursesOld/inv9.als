module alloy4fun_augmented_coursesOld_inv9
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

pred inv9_oracle[] {
all p : Person | no (p.teaches.~teaches - p) & p.teaches.~enrolled
}

pred inv9_correct_0[] {
all p1,p2:Person, c1,c2:Course | c1 in p1.teaches and c1 in p2.teaches and p1!=p2 and c2 in p1.teaches implies c2 not in p2.enrolled
}

pred inv9_correct_1[] {
all c1, c2 : Course, p1, p2 : teaches.c1 | p1 != p2 implies p1 in teaches.c2 implies p2 not in enrolled.c2
}

pred inv9_correct_2[] {
all disj p1, p2 : Person | some p1.teaches & p2.teaches implies no p1.teaches & p2.enrolled
}

pred inv9_correct_3[] {
all p: Person | no ((p.teaches.~teaches)-p) & enrolled.(p.teaches)
}

pred inv9_correct_4[] {
all c1, c2 : Course, p1, p2 : teaches.c1 | p1!=p2 implies p1->c2 in teaches implies p2->c2 not in enrolled
}

pred inv9_correct_5[] {
all c1 : Course, p1, p2 : teaches.c1 | p1!=p2 implies all c2 : Course | p1->c2 in teaches implies p2->c2 not in enrolled
}

