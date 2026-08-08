module alloy4fun_augmented_coursesOld_inv6
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

pred inv6_oracle[] {
all p : Person | p.projects in p.enrolled.projects
}

pred inv6_correct_0[] {
Person<:projects in enrolled.projects
}

pred inv6_correct_1[] {
all p : Person | all p2 : Project | p->p2 in projects implies (some c1 : Course | c1->p2 in projects and p->c1 in enrolled)
}

pred inv6_correct_2[] {
all p : Project | all s : Person | s->p in projects implies (some c : Course | c->p in projects and s->c in enrolled)
}

pred inv6_correct_3[] {
all p : Person | all pro : Project | pro in p.projects implies ( some c : Course | pro in c.projects and c in p.enrolled)
}

pred inv6_correct_4[] {
all p : Project | projects.p <: Person in enrolled.(projects.p <: Course)
}

pred inv6_correct_5[] {
all p1 : Person | all pr1 : Project | p1->pr1 in projects implies (some c1 : Course| c1->pr1 in projects and p1->c1 in enrolled)
}

pred inv6_correct_6[] {
all s1 : Person | all p1 : Project | 
  	s1->p1 in projects implies (some c1 : Course | c1->p1 in projects and s1->c1 in enrolled)
}

pred inv6_correct_7[] {
all s1 : Person | all p1 : Project | 
  	p1 in s1.projects implies (some c1 : Course | c1->p1 in projects and s1->c1 in enrolled)
}

pred inv6_correct_8[] {
all s:Person,p:Project | s->p in projects implies s->p in enrolled.projects
}

pred inv6_correct_9[] {
all s : Person, p : Project | p in s.projects implies (some c : Course | p in c.projects and c in s.enrolled)
}

pred inv6_correct_10[] {
all p: Project | (Person<:projects).p in enrolled.projects.p
}

pred inv6_correct_11[] {
all p : Person | all pr : Project | pr in p.projects implies (some c : Course | pr in c.projects and c in p.enrolled)
}

pred inv6_correct_12[] {
all p: Project, u: Person | p in u.projects implies some c: Course | c in u.enrolled and p in c.projects
}

pred inv6_correct_13[] {
all s1 : Person | all p1 : Project | 
  	p1 in s1.projects implies (some c1 : Course | p1 in c1.projects and c1 in s1.enrolled)
}

pred inv6_correct_14[] {
all s : Person | all p : Project | p in s.projects implies some c : Course | p in c.projects and c in s.enrolled
}

