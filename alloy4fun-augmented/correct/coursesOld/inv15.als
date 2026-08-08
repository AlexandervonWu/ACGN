module alloy4fun_augmented_coursesOld_inv15
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

pred inv15_oracle[] {
all c : Course, p : c.projects, disj x,y : (Person <: projects).p | some c.grades[x] and some c.grades[y] implies c.grades[x] in c.grades[y].(prev+iden+next)
}

pred inv15_correct_0[] {
all c:Course,p:Project,s1,s2:Person | c->p in projects and s1->p in projects and s2->p in projects and (some g:Grade | c->s2->g in grades) implies all g:Grade | c->s1->g in grades implies c->s2->g in grades.(iden+next+prev) or s1=s2
}

pred inv15_correct_1[] {
all c:Course,p:Project,disj s1,s2:Person | c->p in projects and s1->p in projects and s2->p in projects and (some g:Grade | c->s2->g in grades) implies all g:Grade | c->s1->g in grades implies c->s2->g in grades.(iden+next+prev)
}

pred inv15_correct_2[] {
all c:Course,p:c.projects,disj s1,s2:Person<:projects.p | some s2.(c.grades) implies s1.(c.grades) in s2.(c.grades).(iden+next+prev)
}

pred inv15_correct_3[] {
all c:Course,p:Project,disj s1,s2:Person | c->p in projects and s1->p in projects and s2->p in projects and some s2.(c.grades) implies s1.(c.grades) in s2.(c.grades).(iden+next+prev)
}

