module alloy4fun_augmented_coursesNew_inv6
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
(Person <: projects) in enrolled.projects
}

pred inv6_correct_1[] {
all p : Project | all s : Person | p in s.projects implies some c : Course | p in c.projects and s in enrolled.c
}

pred inv6_correct_2[] {
all p:Project| (Person <: projects) in enrolled.projects
}

pred inv6_correct_3[] {
all s : Person | all p : Project | p in s.projects implies s in enrolled.projects.p
}

pred inv6_correct_4[] {
all s1 : Person | all p1 : Project | 
  	s1->p1 in projects implies (some c1 : Course | c1->p1 in projects and s1->c1 in enrolled)
}

pred inv6_correct_5[] {
all x: Person| all p: Project | p in x.projects implies (some c: Course| p in c.projects and c in x.enrolled)
}

pred inv6_correct_6[] {
all s1 : Person | all ps : Project | ps in s1.projects implies (some c1 : Course | ps in c1.projects and c1 in s1.enrolled)
}

pred inv6_correct_7[] {
all p: Project | all pe: Person | p in pe.projects implies p in pe.enrolled.projects
}

