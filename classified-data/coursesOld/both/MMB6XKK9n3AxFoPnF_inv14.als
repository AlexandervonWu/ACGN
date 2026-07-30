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

pred inv14 {
not some s: Student | some c: Course| s->c in teaches
  
  
  
  all s1, s2: Student, p: Project | s1->p in Student <: projects and s2->p in Student <: projects
  implies (not some p2: Project| s1->p2 in Student <: projects and s2->p2 in Student <: projects and p!=p2)
}

pred inv14c {
	all p : Person, disj x,y : p.projects | no ((Person <: projects).x & projects.y) - p
}

check correct { inv14 <=> inv14c}
pred under { inv14 and !inv14c}
pred over { !inv14 and inv14c}
run over 
run under 

