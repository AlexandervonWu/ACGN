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
all disj s, s1 : Student, p : s.projects & s1.projects | one s.((projects.p <: Course).grades) and 
  	one s1.((projects.p <: Course).grades) and (
  	s.((projects.p <: Course).grades) = next[s1.((projects.p <: Course).grades)] or 
  	s.((projects.p <: Course).grades) = prev[s1.((projects.p <: Course).grades)] or 
  	s.((projects.p <: Course).grades) =      s1.((projects.p <: Course).grades))
}

pred inv15c {
	all c : Course, p : c.projects, disj x,y : (Person <: projects).p | some c.grades[x] and some c.grades[y] implies c.grades[x] in c.grades[y].(prev+iden+next)
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 

