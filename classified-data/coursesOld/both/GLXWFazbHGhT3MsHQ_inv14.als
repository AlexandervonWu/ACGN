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
all s1,s2,p,p1,p2 : univ | s1 in Student and s2 in Student and p in Project and p1 in Project and p2 in Project and s1->p in Person <: projects and s2->p in Person <:projects and s1->p1 in Person <: projects and s2->p2 in Person <:projects implies p1!=p2
}

pred inv14c {
	all p : Person, disj x,y : p.projects | no ((Person <: projects).x & projects.y) - p
}

check correct { inv14 <=> inv14c}
pred under { inv14 and !inv14c}
pred over { !inv14 and inv14c}
run over 
run under 

