module alloy4fun_augmented_courses_inv2
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
all p:Person |all c:Course | c in p.teaches implies p in Professor
}

pred inv2_correct_1[] {
all p : Person, c : Course | p in teaches.c implies p in Professor
}

pred inv2_correct_2[] {
all x: Person | all c: Course | c in x.teaches => x in Professor
}

pred inv2_correct_3[] {
teaches.Course in Professor
}

pred inv2_correct_4[] {
all u:Person, c:Course| u->c in teaches implies u in Professor
}

pred inv2_correct_5[] {
all p1: Person | all c1 : Course | p1->c1 in teaches implies p1 in Professor
}

pred inv2_correct_6[] {
all x: Person , y: Course | (x not in Professor) implies (x not in y.~teaches)
}

pred inv2_correct_7[] {
all p : teaches.Course | p in Professor
}

pred inv2_correct_8[] {
all s : Person - Professor | no s.teaches
}

pred inv2_correct_9[] {
all p : Person | all c : Course | p in teaches.c implies p in Professor
}

pred inv2_correct_10[] {
all p: Person - Professor | no p.teaches
}

pred inv2_correct_11[] {
all x: Person - Professor | no x.teaches
}

pred inv2_correct_12[] {
all x:Person, c:Course| x->c in teaches implies x in Professor
}

pred inv2_correct_13[] {
all c:Course, p:Person | p in teaches.c implies p in Professor
}

pred inv2_correct_14[] {
no (Person-Professor).teaches
}

pred inv2_correct_15[] {
all p : Person | some p.teaches implies p in Professor
}

pred inv2_correct_16[] {
all x: Person | some (x.teaches) implies x in Professor
}

pred inv2_correct_17[] {
all p : Person | (p not in Professor) implies (p.teaches=none)
}

pred inv2_correct_18[] {
all c : Course | teaches.c in Professor
}

pred inv2_correct_19[] {
all p:Person, c:Course| c in p.teaches implies p in Professor
}

pred inv2_correct_20[] {
all x:Person, y: Course| x->y in teaches implies x in Professor
}

pred inv2_correct_21[] {
all x : Person | all y : Course | x in teaches.y implies x in Professor
}

pred inv2_correct_22[] {
all s : Person | s not in Professor implies #(s.teaches)=0
}

pred inv2_correct_23[] {
all p:Person | p not in Professor implies no p.teaches
}

pred inv2_correct_24[] {
all x: Person - Professor |all c: Course| c not in x.teaches
}

pred inv2_correct_25[] {
all c : Course | all p : teaches.c | p in Professor
}

pred inv2_correct_26[] {
all x : teaches.Course | x in Professor
}

pred inv2_correct_27[] {
(Person-Professor).teaches = none
}

pred inv2_correct_28[] {
all x: Person | x not in Professor implies #(x.teaches)=0
}

pred inv2_correct_29[] {
all p : Person | #p.teaches > 0 implies p in Professor
}

pred inv2_correct_30[] {
all p: Person | p not in Professor => p not in Course.~teaches
}

pred inv2_correct_31[] {
all p: Person, c: Course | p not in Professor => p not in c.~teaches
}

pred inv2_correct_32[] {
all p:Person | all c:Course | p->c in teaches implies p in Professor
}

pred inv2_correct_33[] {
all t : Person - Professor | no t.teaches
}

pred inv2_correct_34[] {
all p : Person | some p.teaches implies p in Professor
  	all p : Person, c : Course | p->c in teaches implies p in Professor
}

pred inv2_correct_35[] {
all c : Course | all p : Person-Professor | no p & teaches.c
}

pred inv2_correct_36[] {
all p:Person, c:Course| p->c in teaches implies p in Professor
}

pred inv2_correct_37[] {
no (teaches.Course - Professor)
}

pred inv2_correct_38[] {
all t : teaches.Course | t in Professor
}

pred inv2_correct_39[] {
all x: Person, y: Course | not (x not in Professor) or x not in y.~teaches
}

pred inv2_correct_40[] {
all x : Person | all y : Course | x not in Professor implies x not in teaches.y
}

pred inv2_correct_41[] {
all x: Person , y: Course | (x not in Professor) implies (y not in x.teaches)
}

pred inv2_correct_42[] {
all p:Person | not (no p.teaches) implies p in Professor
}

pred inv2_correct_43[] {
all p : Person | some p.teaches implies p in Professor
  	all p : Person, c : Course | p->c in teaches implies p in Professor
  	all p : Person, c : Course | c in p.teaches => p in Professor
}

pred inv2_correct_44[] {
all x: Person | #x.teaches > 0 => x in Professor
}

pred inv2_correct_45[] {
all p : Person | p in teaches.Course => p in Professor
}

pred inv2_correct_46[] {
all c : Course, p : Person | c in p.teaches implies p in Professor
}

pred inv2_correct_47[] {
all p : Person | p.teaches != none => p in Professor
}

pred inv2_correct_48[] {
all x: Person, y: Course | y in x.teaches implies x in Professor
}

pred inv2_correct_49[] {
all p : Person - Professor| #(p.teaches) = 0
}

pred inv2_correct_50[] {
all student : Person - Professor | no student.teaches
}

pred inv2_correct_51[] {
all p1 : Person | all c1 : Course | c1 in p1.teaches implies p1 in Professor
}

