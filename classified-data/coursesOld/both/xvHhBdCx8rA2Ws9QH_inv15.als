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
all p : Project | all s1, s2 : Student | s1->p in projects and s2->p in projects and s1 != s2 => 
  	( all g1, g2: Grade, c : Course | c->s1->g1 in grades and c->s2->g2 in grades => (g1 = g2 or g1 = prev[g2] or g2 = prev[g1]) )
}

pred inv15c {
	all c : Course, p : c.projects, disj x,y : (Person <: projects).p | some c.grades[x] and some c.grades[y] implies c.grades[x] in c.grades[y].(prev+iden+next)
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 

