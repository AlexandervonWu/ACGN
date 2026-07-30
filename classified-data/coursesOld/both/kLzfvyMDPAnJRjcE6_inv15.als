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

pred inv15 {
all disj p: Project, disj s1,s2: Student, c : Course | p in s1.projects and p in s2.projects and p in c.projects => c.grades[s1]-1 = c.grades[s2]
}

pred inv15c {
	all c : Course, p : c.projects, disj x,y : (Person <: projects).p | some c.grades[x] and some c.grades[y] implies c.grades[x] in c.grades[y].(prev+iden+next)
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 

