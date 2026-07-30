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

pred inv14 {
all s1, s2 : Student, proj:Project | proj in s1.projects and proj in s2.projects and s1!=s2 implies (some proj2 : Project | (proj2 in s1.projects and proj2 not in s2.projects) or (proj2 in s2.projects and proj2 not in s1.projects))
}

pred inv14c {
	all p : Person, disj x,y : p.projects | no ((Person <: projects).x & projects.y) - p
}

check correct { inv14 <=> inv14c}
pred under { inv14 and !inv14c}
pred over { !inv14 and inv14c}
run over 
run under 

