module alloy4fun_augmented_coursesOld_inv4
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
all p : univ | p in Project implies some c1 : univ | c1 in Course and c1->p in Course<:projects and all c2 : univ | c2 in Course and c2->p in Course<:projects implies c1 = c2
}

pred inv4_correct_1[] {
all c1,c2: Course, p: Project | p in c1.projects and p in c2.projects implies c1=c2
  	
  	Project in Course.projects
}

pred inv4_correct_2[] {
all p:Project | one c:Course | c->p in projects
}

pred inv4_correct_3[] {
all p : Project | one c : Course | p in c.projects
}

pred inv4_correct_4[] {
all p:Project | one Course<:projects.p
}

pred inv4_correct_5[] {
all p : Project | one (Course:>projects.p)
}

pred inv4_correct_6[] {
all p : Project | one p.~(Course<:projects)
}

pred inv4_correct_7[] {
all x:Project | one y:Course| y->x in projects
}

pred inv4_correct_8[] {
all x : Project | one projects.x <: Course
}

pred inv4_correct_9[] {
all pro: Project | #pro.~{Course <: projects} = 1
}

pred inv4_correct_10[] {
all proj:Project | one (Course<:projects).proj
}

pred inv4_correct_11[] {
all p:Project | one (projects.p & Course)
}

pred inv4_correct_12[] {
(Course <: projects) in Course one -> set Project
}

pred inv4_correct_13[] {
all p : Project | p in Course.projects
	all c1,c2 : Course | all p: Project | (p in c1.projects and p in c2.projects) implies c1 = c2
}

pred inv4_correct_14[] {
all p: Project | one course : Course | p in course.projects
}

pred inv4_correct_15[] {
all proj: Project | one course: Course | proj in course.projects
}

pred inv4_correct_16[] {
all x: Project| one y: Course |  x in y.projects
}

pred inv4_correct_17[] {
all p1 : Project | one c1 : Course | c1->p1 in projects
}

pred inv4_correct_18[] {
all p:Project | p in Course.projects
  	all p:Project,c1,c2:Course | p in c1.projects and p in c2.projects implies c1=c2
}

pred inv4_correct_19[] {
all p : Project | some c : Course | c->p in projects and all c1,c2 : Course | c1->p in projects and c2->p in projects implies c1=c2
}

pred inv4_correct_20[] {
all disj p: Project | #(Course <: projects).p = 1
}

pred inv4_correct_21[] {
all proj:Project, c1, c2:Course | c1->proj in projects and c2->proj in projects => c1=c2
  	all proj:Project | some c:Course | c->proj in projects
}

pred inv4_correct_22[] {
all proj:Project | one c:Course | c->proj in projects
}

pred inv4_correct_23[] {
all p : Project | one projects & Course->p
}

pred inv4_correct_24[] {
all p: Project | p in Course.projects
	all p: Project, c1, c2: Course | c1 in projects.p and c2 in projects.p implies c1=c2
}

pred inv4_correct_25[] {
all p : Project | p in Course.projects
  all c1,c2 : Course, p : Project | p in c1.projects and p in c2.projects implies c1=c2
}

pred inv4_correct_26[] {
all p : Project | p in Course.projects
	all p : Project | all c1,c2 : Course | p in c1.projects and p in c2.projects implies c1=c2
}

pred inv4_correct_27[] {
all p : Project | one projects.p :> Course
}

pred inv4_correct_28[] {
all p : Project | one projects.p <: Course
}

pred inv4_correct_29[] {
all p : Project | one Course & (projects.p)
}

pred inv4_correct_30[] {
all x: Project | one c: Course | c->x in projects
}

pred inv4_correct_31[] {
all x : Project | one projects.x & Course
}

pred inv4_correct_32[] {
all p: Project | (one c: Course | c in projects.p)
}

pred inv4_correct_33[] {
all p : Project | some c : Course | c->p in projects and Course <: projects in Course one -> set Project
}

pred inv4_correct_34[] {
all x:Project | one y:Course | y in projects.x
}

pred inv4_correct_35[] {
all p:Project | some c:Course | c->p in projects
  	all c1,c2:Course | (some p:Project | c1->p in projects and c2->p in projects) implies c1 = c2
}

pred inv4_correct_36[] {
all p : Project | some c1 : Course | c1->p in Course<:projects and all c2 : Course | c2->p in Course<:projects implies c1 = c2
}

pred inv4_correct_37[] {
all p : Project | all c1,c2 : Course | c1->p in projects and c2 ->p in projects implies c1=c2
  	all p : Project | some c : Course | c -> p in projects
}

pred inv4_correct_38[] {
all p : Project | p in Course.projects
	all disj c1, c2 : Course | all p : Project | p in c1.projects implies p not in c2.projects
}

pred inv4_correct_39[] {
all p : Project | p in Course.projects
	all p : Project | all c1,c2 : Course | c1->p in projects and p in c2.projects implies c1=c2
}

pred inv4_correct_40[] {
all a : Project | one b : Course | a in b.projects
}

pred inv4_correct_41[] {
all p:Project | one c1:Course | c1->p in projects
}

pred inv4_correct_42[] {
all tp : Project | one c : Course | tp in c.projects
}

