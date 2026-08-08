module alloy4fun_augmented_coursesOld_inv14
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

pred inv14_oracle[] {
all p : Person, disj x,y : p.projects | no ((Person <: projects).x & projects.y) - p
}

pred inv14_correct_0[] {
all p1, p2 : Project, s1, s2 : Person<:projects.p1 | s1 != s2 and p1 != p2 implies s1->p2 not in Person<:projects or s2->p2 not in Person<:projects
}

pred inv14_correct_1[] {
all p1,p2:Person, j1,j2:Project | p1->j1 in projects and p2->j1 in projects and p1->j2 in projects and p2->j2 in projects implies p1 = p2 or j1 = j2
}

pred inv14_correct_2[] {
all s1, s2 : Person | lone s1.projects & s2.projects or s1 = s2
}

pred inv14_correct_3[] {
all disj p1, p2 : Person | lone p1.projects & p2.projects
}

pred inv14_correct_4[] {
all p1, p2 : Project, s1, s2 : Person<:projects.p1 | s1 != s2 and p1 != p2 implies p2 not in s1.projects or p2 not in s2.projects
}

pred inv14_correct_5[] {
all p1, p2 : Project, s1, s2 : Person<:projects.p1 | s1 != s2 and p1 != p2 implies p2 not in s1.projects&s2.projects
}

pred inv14_correct_6[] {
all p1:Person, j1,j2:p1.projects | p1 = Person<:projects.j1 & Person<:projects.j2 or j1 = j2
}

