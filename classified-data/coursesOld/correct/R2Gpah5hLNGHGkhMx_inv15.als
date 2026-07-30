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
all c:Course,p:Project,s1,s2:Person | c->p in projects and s1->p in projects and s2->p in projects and (some g:Grade | c->s2->g in grades) implies all g:Grade | c->s1->g in grades implies c->s2->g in grades.(iden+next+prev) or s1=s2
}

pred inv15c {
	all c : Course, p : c.projects, disj x,y : (Person <: projects).p | some c.grades[x] and some c.grades[y] implies c.grades[x] in c.grades[y].(prev+iden+next)
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 

