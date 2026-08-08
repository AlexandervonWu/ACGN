module alloy4fun_augmented_coursesNew_inv1
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

pred inv1_oracle[] {
enrolled in Student -> Course
}

pred inv1_correct_0[] {
all p:Person | all c:Course | p->c in enrolled implies p in Student
}

pred inv1_correct_1[] {
all p: Person - Student | no p.enrolled
}

pred inv1_correct_2[] {
all x : Person | all y : Course | x not in Student implies x not in enrolled.y
}

pred inv1_correct_3[] {
all p:Person, c:Course | c in p.enrolled implies p in Student
}

pred inv1_correct_4[] {
all p : Person, c : Course | p in enrolled.c => p in Student
}

pred inv1_correct_5[] {
all x: Person, y: Course | x not in Student => x not in y.~enrolled
}

pred inv1_correct_6[] {
all x: Person - Student | no x.enrolled
}

pred inv1_correct_7[] {
all p:Person | all c:Course | (c in p.enrolled) implies p in Student
}

pred inv1_correct_8[] {
all p : Person | some p.enrolled implies p in Student
}

pred inv1_correct_9[] {
all p : Person - Student | #(p.enrolled) = 0
}

pred inv1_correct_10[] {
no (Person - Student).enrolled
}

pred inv1_correct_11[] {
all x: Person , y: Course | (x not in Student) implies y not in x.enrolled
}

pred inv1_correct_12[] {
all s : Person - Student | no s.enrolled
}

pred inv1_correct_13[] {
all c : Course | all p : Person-Student | no p & enrolled.c
}

pred inv1_correct_14[] {
all x: Person, y: Course| x->y in enrolled implies x in Student
}

pred inv1_correct_15[] {
all p : Person | p.enrolled != none => p in Student
}

pred inv1_correct_16[] {
all p : Person | p not in Student implies p.enrolled=none
}

pred inv1_correct_17[] {
all p:Person | not (no p.enrolled) implies p in Student
}

pred inv1_correct_18[] {
all x: Person | some x.enrolled implies x in Student
}

pred inv1_correct_19[] {
all p:Person | p not in Student implies no p.enrolled
}

pred inv1_correct_20[] {
all p: Person | p not in Student => p not in Course.~enrolled
}

pred inv1_correct_21[] {
all x : Person | all y : Course | x in enrolled.y implies x in Student
}

pred inv1_correct_22[] {
all x: Person | all y: Course | (x not in Student) implies y not in x.enrolled
}

pred inv1_correct_23[] {
all p : Person - Student | all c : Course | c not in p.enrolled
}

pred inv1_correct_24[] {
all x: Person, y: Course | y in x.enrolled implies x in Student
}

pred inv1_correct_25[] {
all x: Person | x not in Student implies #(x.enrolled)=0
}

pred inv1_correct_26[] {
all p : enrolled.Course | p in Student
}

pred inv1_correct_27[] {
all p : Person, c: Course | p->c in enrolled implies p in Student
}

pred inv1_correct_28[] {
all x : Person | x in enrolled.Course implies x in Student
}

pred inv1_correct_29[] {
all c : Course | enrolled.c in Student
}

pred inv1_correct_30[] {
all p : Person | all c : Course | p in enrolled.c implies p in Student
}

pred inv1_correct_31[] {
all person : univ | all courses : Course | person->courses in enrolled implies person in Student
}

pred inv1_correct_32[] {
enrolled.Course in Student
}

pred inv1_correct_33[] {
all p : Person | #(p.enrolled)>0 implies p in Student
}

pred inv1_correct_34[] {
all p1 : Person | all c1 : Course | p1->c1 in enrolled implies p1 in Student
}

pred inv1_correct_35[] {
all u:Person, c:Course| u->c in enrolled implies u in Student
}

pred inv1_correct_36[] {
all c:Course,p:Person| p in enrolled.c => p in Student
}

pred inv1_correct_37[] {
(Person-Student).enrolled = none
}

pred inv1_correct_38[] {
all x: Person | all c: Course | c in x.enrolled => x in Student
}

pred inv1_correct_39[] {
all p:Person| p in enrolled.Course implies p in Student
}

pred inv1_correct_40[] {
all x: Person | #x.enrolled > 0 => x in Student
}

pred inv1_correct_41[] {
all x: Person - Student | x.enrolled = none
}

pred inv1_correct_42[] {
all s : Person | s not in Student implies #(s.enrolled)=0
}

pred inv1_correct_43[] {
all u : enrolled.Course | u in Student
}

pred inv1_correct_44[] {
all c : Course, e : Person | e in enrolled.c => e in Student
}

pred inv1_correct_45[] {
all c : Course | all p : enrolled.c | p in Student
}

pred inv1_correct_46[] {
all x : Course | enrolled.x in Student
}

pred inv1_correct_47[] {
all x: Person - Student | all c: Course| c not in x.enrolled
}

pred inv1_correct_48[] {
all professor : Person - Student | no professor.enrolled
}

pred inv1_correct_49[] {
no enrolled.Course - Student
}

pred inv1_correct_50[] {
all p: Person, c: Course | p in c.~enrolled implies p in Student
}

pred inv1_correct_51[] {
all c : Course, p : Person | c in p.enrolled implies p in Student
}

pred inv1_correct_52[] {
all p:Person, c:Course| some p.enrolled => p in Student
}

pred inv1_correct_53[] {
all p, e: univ | p in Person and p->e in enrolled implies p in Student
}

pred inv1_correct_54[] {
all p: Person, c: Course | p not in Student => p not in c.~enrolled
}

pred inv1_correct_55[] {
all x:Person, c:Course| x->c in enrolled implies x in Student
}

pred inv1_correct_56[] {
all x: Person | x not in Student => x not in Course.~enrolled
}

pred inv1_correct_57[] {
all p1 : Person | all c1 : Course | c1 in p1.enrolled implies p1 in Student
}

pred inv1_correct_58[] {
all x:Person, c:Course | x in enrolled.c implies x in Student
}

pred inv1_correct_59[] {
all c : Course | all p : Person-Student | not p in enrolled.c
}

pred inv1_correct_60[] {
all p : Person, c : Course | p in enrolled.Course => p in Student
}

