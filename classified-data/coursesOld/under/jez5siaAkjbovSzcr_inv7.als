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
all u : Student, c1,c2 : Course, p1,p2 : Project | p1 in u.projects and p2 in u.projects and p1 in c1.projects and p2 in c2.projects implies p1=p2 or c1!=c2
}

pred inv7c {
	all p : Person, c : Course | lone p.projects & c.projects
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 

