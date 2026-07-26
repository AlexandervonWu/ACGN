module alloy4fun_augmented_courses_inv7
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

pred inv7_oracle[] {
all p : Person, c : Course | lone p.projects & c.projects
}

pred inv7_correct_0[] {
all p : Person, c : Course , ps1,ps2 : Project | ps1 in p.projects && ps2 in p.projects && ps1 in c.projects && ps2 in c.projects implies ps1 = ps2
}

pred inv7_correct_1[] {
all s : Person | all p1, p2 : Project | all c : Course | s in projects.p1 and s in projects.p2 and c in projects.p1 and c in projects.p2 implies p1 = p2
}

pred inv7_correct_2[] {
all x:Person, y:Course, v,z: Project|  x-> z in projects and x-> v in projects and y -> v in projects and y-> z in projects implies v= z
}

pred inv7_correct_3[] {
all s1 : Person | all ps1,ps2 : Project | ps1 in s1.projects and ps2 in s1.projects and (some c1 : Course | ps1 in c1.projects and ps2 in c1.projects) implies ps1 = ps2
}

pred inv7_correct_4[] {
all pro1,pro2 : Project | all per : Person | all c : Course | ( pro1 in per.projects and pro2 in per.projects and pro1 in c.projects and pro1 != pro2) implies pro2 not in c.projects
}

pred inv7_correct_5[] {
all s : Person | all c : Course | lone s.projects & c.projects
}

