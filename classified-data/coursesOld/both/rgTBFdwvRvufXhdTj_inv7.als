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

pred inv7 {
all s : Student | all p1,p2 : Project | all c : Course | (p1 in s.projects and p2 in s.projects and p1 in c.projects and p2 in c.projects) implies p1 = p2

  all s : Student | all p : Project | all c1, c2 : Course | p in c1.projects and p in c2.projects and p in s.projects implies c1 = c2
}

pred inv7c {
	all p : Person, c : Course | lone p.projects & c.projects
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 

