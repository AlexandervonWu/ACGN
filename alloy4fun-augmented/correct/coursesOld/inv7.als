module alloy4fun_augmented_coursesOld_inv7
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
all c:Course,j1,j2:Project | (c->j1 in projects and c->j2 in projects and some p:Person | p->j1 in projects and p->j2 in projects) implies j1 = j2
}

pred inv7_correct_1[] {
all c:Course,p:Person | lone p.projects & c.projects
}

pred inv7_correct_2[] {
all c:Course,j1,j2:Project | (j1 in c.projects and j2 in c.projects and some p:Person | p->j1 in projects and p->j2 in projects) implies j1 = j2
}

pred inv7_correct_3[] {
all s:Person, c:Course, p1,p2 : Project | p1 in s.projects and p1 in c.projects and p2 in s.projects and p2 in c.projects implies p1=p2
}

pred inv7_correct_4[] {
all c:Course | Person <: projects :> c.projects in Person -> lone Project
}

