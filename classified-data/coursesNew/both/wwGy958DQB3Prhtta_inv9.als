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

pred inv9 {
all x,y:Person | one c:Course| x->c in teaches and y-> c in teaches and x in Professor and y in Professor implies x-> c not in enrolled or y->c not in enrolled
}

pred inv9c {
	all p : Person | no (p.teaches.~teaches - p) & p.teaches.~enrolled
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 

