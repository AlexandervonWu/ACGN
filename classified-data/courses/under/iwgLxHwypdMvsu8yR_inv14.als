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
(all ref0,ref1:(one Student),ref2,ref3:(one Project)|((((ref0 -> ref2) in (Person <: projects)) && ((ref0 -> ref3) in (Person <: projects)) && ((ref1 -> ref2) in (Person <: projects)) && (ref0 != ref1) && (ref2 != ref3)) => ((ref1 -> ref3) !in (Person <: projects))))
}

pred inv14c {
	all p : Person, disj x,y : p.projects | no ((Person <: projects).x & projects.y) - p
}

check correct { inv14 <=> inv14c}
pred under { inv14 and !inv14c}
pred over { !inv14 and inv14c}
run over 
run under 

