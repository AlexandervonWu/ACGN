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
all s: Student, c: Course, p1: Project, p2: Project | p1 != p2 and c in s.enrolled and p1 in s.(Person <: projects) and p2 in s.(Person <: projects) implies (p1 in c.(Course <: projects) and p2 not in c.(Course <: projects))
}

pred inv7c {
	all p : Person, c : Course | lone p.projects & c.projects
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 

