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
all student: Student | all proj: Project | all course: Course | proj in student.projects and proj in course.projects implies lone proj
}

pred inv7c {
	all p : Person, c : Course | lone p.projects & c.projects
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 

