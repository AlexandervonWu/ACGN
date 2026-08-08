module alloy4fun_augmented_coursesOld_inv2
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

pred inv2_oracle[] {
teaches in Professor -> Course
}

pred inv2_correct_0[] {
no teaches.Course - Professor
}

pred inv2_correct_1[] {
all p : Person - Professor | p.teaches = none
}

pred inv2_correct_2[] {
all p:Person, c:Course | p in teaches.c implies p in Professor
}

pred inv2_correct_3[] {
all p : Person | all c : Course | p->c in teaches implies p in Professor
}

pred inv2_correct_4[] {
all course: Course | all person: Person | course in person.teaches implies person in Professor
}

pred inv2_correct_5[] {
all p : Person | all c : Course | c in p.teaches implies p in Professor
}

pred inv2_correct_6[] {
no ((Person-Professor).teaches)
}

pred inv2_correct_7[] {
all c:Course | teaches.c in Professor
}

pred inv2_correct_8[] {
all c : Course | all p : Person | p->c in teaches implies p in Professor
}

pred inv2_correct_9[] {
no (Person - Professor) & teaches.Course
}

pred inv2_correct_10[] {
all p,c : univ | p in Person and c in Course and p->c in teaches implies p in Professor
}

pred inv2_correct_11[] {
Course.~teaches in Professor
}

pred inv2_correct_12[] {
all c : Course, p : Person | (p -> c in teaches) implies p in Professor
}

pred inv2_correct_13[] {
all p:Person , c:Course | p->c in teaches implies p in Professor
}

pred inv2_correct_14[] {
all p : Person | all t : Course | t in p.teaches implies p in Professor
}

pred inv2_correct_15[] {
(teaches . Course) in Professor
}

pred inv2_correct_16[] {
all p : Person |p in teaches.Course implies p in Professor
}

pred inv2_correct_17[] {
all x: Person, y: Course | y in x.teaches implies x in Professor
}

pred inv2_correct_18[] {
all p:Person | some (p.teaches) implies (p in Professor)
}

pred inv2_correct_19[] {
all x: Person, c: Course | x->c in teaches implies x in Professor
}

pred inv2_correct_20[] {
all p : Person | (some c: Course | p -> c in teaches) => (p in Professor)
}

pred inv2_correct_21[] {
no teaches.Course & (Person-Professor)
}

pred inv2_correct_22[] {
all p: univ | all c: Course | p->c in teaches implies p in Professor
}

pred inv2_correct_23[] {
all p : Person, c : Course | c in p.teaches implies p in Professor
}

pred inv2_correct_24[] {
all x : Course, y : Person - Professor | y->x not in teaches
  	no (Person - Professor) & teaches.Course
}

pred inv2_correct_25[] {
all x:Course, y:Person-Professor | y->x not in teaches
}

pred inv2_correct_26[] {
all x:Person, c:Course | x in teaches.c implies x in Professor
}

pred inv2_correct_27[] {
all p:Person, c: Course | no (p & Professor) implies c not in p.teaches
}

pred inv2_correct_28[] {
all c:Course | c.(~teaches) in Professor
}

pred inv2_correct_29[] {
all p:Person, c:Course | p in Professor or p->c not in teaches
}

pred inv2_correct_30[] {
no Course.~teaches - Professor
}

pred inv2_correct_31[] {
all p:Person-Professor, c:Course | c not in p.teaches
}

pred inv2_correct_32[] {
all p : Person | all c : Course | p in teaches.c implies p in Professor
}

pred inv2_correct_33[] {
all p : Person, c : Course | p->c in teaches => p in Professor
  	teaches.Course in Professor
}

pred inv2_correct_34[] {
all a : Person, b : Course | b in a.teaches implies a in Professor
}

pred inv2_correct_35[] {
all p1 : Person | all c1 : Course | p1->c1 in teaches implies p1 in Professor
}

pred inv2_correct_36[] {
all p : teaches.Course | p in Professor
}

pred inv2_correct_37[] {
not some p:Person | some c:Course | p not in Professor and p->c in teaches
}

pred inv2_correct_38[] {
all p: Person , c: Course| p in Professor  or  not(p -> c in teaches)
}

pred inv2_correct_39[] {
all p:Person | all c1:Course | p->c1 in teaches implies p in Professor
}

pred inv2_correct_40[] {
all x:Person-Professor, y:Course | x->y not in teaches
}

pred inv2_correct_41[] {
all c: Course, p: Person | p in c.~teaches implies p in Professor
}

pred inv2_correct_42[] {
all p, c : univ | p in Person and p not in Professor and c in Course implies p->c not in teaches
}

pred inv2_correct_43[] {
all x, y : univ | x->y in teaches implies x in Professor
}

pred inv2_correct_44[] {
all c:Course | not some p:Person-Professor | p->c in teaches
}

pred inv2_correct_45[] {
all person : Person | all course: Course | course in person.teaches implies person in Professor
}

pred inv2_correct_46[] {
all c : Course, p : Person | p->c in teaches implies p in Professor
  	all c : Course | teaches.c in Professor
}

pred inv2_correct_47[] {
all c : Course | all p : Person | c in p.teaches implies p in Professor
}

pred inv2_correct_48[] {
all x: Person | some x.teaches implies x in Professor
}

pred inv2_correct_49[] {
all p : Person, c : Course | p not in Professor implies p->c not in teaches
}

pred inv2_correct_50[] {
all profs: Person-Professor | #profs.teaches = 0
}

pred inv2_correct_51[] {
all c: Course, p: Person | c in p.teaches implies p in Professor
}

pred inv2_correct_52[] {
Professor <: teaches = teaches
}

pred inv2_correct_53[] {
all x : Person, y: Course | x->y in teaches implies x in Professor
}

pred inv2_correct_54[] {
all p : univ | p in Person and p not in Professor implies all c : univ | c in Course implies p->c not in teaches
}

pred inv2_correct_55[] {
all x : Person | x in teaches.Course => x in Professor
}

pred inv2_correct_56[] {
all c:Course, p:Person | no (p & Professor) implies c not in p.teaches
}

pred inv2_correct_57[] {
all p : Person - Professor, c : Course | not p -> c in teaches
}

pred inv2_correct_58[] {
all x : Person - Professor | no x.teaches
}

pred inv2_correct_59[] {
all p : Person-Professor| no p.teaches
}

