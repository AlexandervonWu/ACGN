module alloy4fun_augmented_courses_inv14
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
all p1,p2 : Person | lone pro : Project | pro in p1.projects and pro in p2.projects and p1 != p2
}

pred inv14_correct_1[] {
all p1,p2 : Person | all c1,c2 : Project | (c1 in p1.projects and c1 in p2.projects and c2 in p1.projects and p1!=p2 and c1!=c2 ) implies (c2 not in p2.projects)
}

pred inv14_correct_2[] {
all p1,p2 : Person | all pro1,pro2 : Project | (pro1 in p1.projects and pro1 in p2.projects and pro2 in p1.projects and pro1 != pro2 and p1!=p2) implies (pro2 not in p2.projects)
}

pred inv14_correct_3[] {
all x1,x2 : Person | lone y : Project | y in x1.projects and y in x2.projects and x1!=x2
}

pred inv14_correct_4[] {
all p: Person | all project: p.projects | no ((getProjectStudents[project] & getProjectStudents[p.projects - project]) - p)
}

