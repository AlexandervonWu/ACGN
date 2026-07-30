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
all person1, person2 : Person | all course1, course2 : Course | (course1 in person1.teaches and course2 in person2.teaches) implies (course2 not in person1.enrolled and course1 not in person2.enrolled)
}

pred inv9c {
	all p : Person | no (p.teaches.~teaches - p) & p.teaches.~enrolled
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 

