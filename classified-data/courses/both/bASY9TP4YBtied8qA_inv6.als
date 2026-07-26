open util/ordering[Grade]

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

pred inv6 {
all y:Person, p:Project, c:Course | y->p in projects implies y in Student and y->c in enrolled and c->p in projects
}

pred inv6c {
	all p : Person | p.projects in p.enrolled.projects
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 

