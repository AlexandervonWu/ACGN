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
all s : Person| all p : Project | all c : Course | (p in s.projects) and (p in c.projects) implies (s.enrolled in c)
}

pred inv6c {
	all p : Person | p.projects in p.enrolled.projects
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 

