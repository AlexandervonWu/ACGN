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
all c : Course, disj p0,p1 : Person | ((c in p0.teaches && c in p1.enrolled) => (p0 in Professor && p1 in Student)) && ((c in p1.teaches && c in p0.enrolled) => (p1 in Professor && p0 in Student))
}

pred inv9c {
	all p : Person | no (p.teaches.~teaches - p) & p.teaches.~enrolled
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 

