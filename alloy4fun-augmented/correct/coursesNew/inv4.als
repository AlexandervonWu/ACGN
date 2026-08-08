module alloy4fun_augmented_coursesNew_inv4
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

pred inv4_oracle[] {
all p : Project | one (Course <: projects).p
}

pred inv4_correct_0[] {
all p:Project | one c:Course | p in c.projects
}

pred inv4_correct_1[] {
all p : Project | one Course <: (projects.p)
}

pred inv4_correct_2[] {
all p : Project | #((Course <: projects).p) = 1
}

pred inv4_correct_3[] {
all g:Project | one ( (Course <: projects).g)
}

pred inv4_correct_4[] {
all p: Project| one c:Course | c = projects.p
}

pred inv4_correct_5[] {
all x : Project | one Course <: projects.x
}

pred inv4_correct_6[] {
all p:Project | one c:Course | c->p in projects
}

pred inv4_correct_7[] {
all ps : Project | one c1 : Course | ps in c1.projects
}

pred inv4_correct_8[] {
all x: Project | one p: Course | p->x in projects
}

pred inv4_correct_9[] {
all p: Project | one Course :> projects.p
}

pred inv4_correct_10[] {
all x : Project | one y : Course | y in projects.x
}

pred inv4_correct_11[] {
all p:Project| one projects.p & Course
}

pred inv4_correct_12[] {
all proj:Project | one c:Course | proj in c.projects
}

pred inv4_correct_13[] {
all x : Project | one y : Course | x in y.projects
}

pred inv4_correct_14[] {
all p : Project | one (p.(~(Course <: projects)))
}

pred inv4_correct_15[] {
all p: Project | one c: Course | c in projects.p
}

pred inv4_correct_16[] {
all p: Project | one c: Course | p.~projects = c
}

pred inv4_correct_17[] {
(Course<: projects) in Course one -> set Project
}

pred inv4_correct_18[] {
all x:Project |  one (Course <: projects).x
}

pred inv4_correct_19[] {
all p:Project| #Course:>projects.p=1
}

pred inv4_correct_20[] {
all pr: Project | one c : Course | pr in c.projects
}

pred inv4_correct_21[] {
all project : Project | one course : Course | course->project in projects
}

pred inv4_correct_22[] {
all p : Project | one x : Course | x in projects.p
}

pred inv4_correct_23[] {
all p : Project | #projects.p:>Course = 1
}

pred inv4_correct_24[] {
all p1 : Project | one c1 : Course | c1->p1 in projects
}

pred inv4_correct_25[] {
all p : Project | #Course<:projects.p = 1
}

pred inv4_correct_26[] {
all p : Project | one c : Course | c in p.~(projects)
}

pred inv4_correct_27[] {
all p:Project | one projects.p <: Course
}

pred inv4_correct_28[] {
all x: Project |one c : Course | x in c.projects
}

pred inv4_correct_29[] {
all a:Project | one c:Course | a in c.projects
}

