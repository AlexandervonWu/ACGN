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

pred inv13 {
all c1 : Course | all g1 : Grade | all s1 : Student | some g2 : Grade | some s2 : Student |
  	(c1->s1->g1 in grades and c1->s2->g2 in grades and g2=max[g1])
  
	implies (some p1 : Project | c1->p1 in projects and s2->p1 in projects)
}

pred inv13c {
	all c : Course, p : Person | last in p.(c.grades) implies some p.projects & c.projects
}

check correct { inv13 <=> inv13c}
pred under { inv13 and !inv13c}
pred over { !inv13 and inv13c}
run over 
run under 

