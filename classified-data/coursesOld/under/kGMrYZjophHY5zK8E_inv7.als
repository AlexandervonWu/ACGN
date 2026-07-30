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
all s1 : Student | all p1,p2 : Project | all c1 : Course |
    
    ((s1->p1 in projects) and (s1->p2 in projects) and
     	(c1->p1 in projects) and (c1->p2 in projects)) implies p1=p2
}

pred inv7c {
	all p : Person, c : Course | lone p.projects & c.projects
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 

