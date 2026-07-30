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
all disj s1, s2 : Student | all p : Project, c : Course |
  		s1 + s2 in projects.p
  		&& s1 + s2 in enrolled.c	
  		&& p in c.projects
  		=> s1.(c.grades) = s2.(c.grades)
  			|| (s1.(c.grades)).prev = s2.(c.grades)
  			|| s1.(c.grades) = (s2.(c.grades)).prev
}

pred inv15c {
	all c : Course, p : c.projects, disj x,y : (Person <: projects).p | some c.grades[x] and some c.grades[y] implies c.grades[x] in c.grades[y].(prev+iden+next)
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 

