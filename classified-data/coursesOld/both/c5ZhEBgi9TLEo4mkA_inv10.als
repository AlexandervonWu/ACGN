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

pred inv10 {
all p: Person | all c: p.enrolled | c.grades[p] in Grade
    all s: Student | all c: s.enrolled | c.grades[s] in Grade
    all p: Professor | all c: p.teaches | no c.grades[p]
    all o: Person - Student - Professor | all c: o.enrolled | no c.grades[o]
}

pred inv10c {
	Course.grades.Grade in Student
}

check correct { inv10 <=> inv10c}
pred under { inv10 and !inv10c}
pred over { !inv10 and inv10c}
run over 
run under 

