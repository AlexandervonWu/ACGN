module alloy4fun_augmented_coursesOld_inv1
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
all c: Course | all p: Person | c in p.enrolled implies p in {Student}
}

pred inv1_correct_1[] {
all p:Person, c:Course | p in enrolled.c implies p in Student
}

pred inv1_correct_2[] {
all course: Course | all person: Person | course in person.enrolled implies person in Student
}

pred inv1_correct_3[] {
all profs: Person-Student | #profs.enrolled = 0
}

pred inv1_correct_4[] {
all p:Person | no (Person-Student) & enrolled.Course
}

pred inv1_correct_5[] {
all p: Person, c: Course | p->c in enrolled implies p in Student
}

pred inv1_correct_6[] {
no ((Person-Student).enrolled)
}

pred inv1_correct_7[] {
no Course.~enrolled - Student
}

pred inv1_correct_8[] {
no enrolled.Course-Student
}

pred inv1_correct_9[] {
all p : Person | some p.enrolled implies p in Student
}

pred inv1_correct_10[] {
enrolled . Course in Student
}

pred inv1_correct_11[] {
all p : Person, c : Course | c in p.enrolled implies p in Student
}

pred inv1_correct_12[] {
all p : Person | all c : Course | c in p.enrolled implies p in Student
}

pred inv1_correct_13[] {
all x: Person, y:Course | y in x.enrolled implies x in Student
}

pred inv1_correct_14[] {
Student <: enrolled = enrolled
}

pred inv1_correct_15[] {
all p : Person - Student, c : Course | c not in p.enrolled
}

pred inv1_correct_16[] {
all c: Course, p : Person | p -> c in enrolled implies p in Student
}

pred inv1_correct_17[] {
all x: Person, c: Course | x->c in enrolled implies x in Student
}

pred inv1_correct_18[] {
all s : Person | some s.enrolled implies s in Student
}

pred inv1_correct_19[] {
all x, y : univ | x->y in enrolled implies x in Student
}

pred inv1_correct_20[] {
all c : Course | enrolled.c in Student
}

pred inv1_correct_21[] {
all c : Course | all p : Person | p->c in enrolled implies p in Student
}

pred inv1_correct_22[] {
no (Person-Student) & enrolled.Course
}

pred inv1_correct_23[] {
all c : Course | c.~enrolled in Student
}

pred inv1_correct_24[] {
all p : Person | all c : Course | p->c in enrolled implies p in Student
}

pred inv1_correct_25[] {
all p : Person, c : Course | no ( p & Student ) implies c not in p.enrolled
}

pred inv1_correct_26[] {
all y : Course | enrolled.y in Student
}

pred inv1_correct_27[] {
all p : Person | #p.enrolled > 0 implies p in Student
}

pred inv1_correct_28[] {
all p1 : Person | all c1 : Course | p1->c1 in enrolled implies p1 in Student
}

pred inv1_correct_29[] {
all p : Person, c : Course | no(p & Student) implies not c in p.enrolled
}

pred inv1_correct_30[] {
all c:Course, p:Person | no (p & Student) implies not c in  p.enrolled
}

pred inv1_correct_31[] {
all x : Person - Student | no x.enrolled
}

pred inv1_correct_32[] {
all x : Course, y : Person - Student | y->x not in enrolled 
  	no (Person - Student) & enrolled.Course
}

pred inv1_correct_33[] {
all u : Person | all c : Course | c in u.enrolled implies u in Student
}

pred inv1_correct_34[] {
all p : Person - Student | p.enrolled = none
}

pred inv1_correct_35[] {
all p : Person - Student | all c : Course | not p -> c in enrolled
}

pred inv1_correct_36[] {
all p : Person, c : Course | some p.enrolled => p in Student
}

pred inv1_correct_37[] {
all x : Person | x in enrolled.Course => x in Student
}

pred inv1_correct_38[] {
all c:Course | c not in (Person - Student).enrolled
}

pred inv1_correct_39[] {
all p,c : univ | p in Person and c in Course and p->c in enrolled implies p in Student
}

pred inv1_correct_40[] {
all c: Course, p: Person | p in c.~enrolled implies p in Student
}

pred inv1_correct_41[] {
all p1 : Person | all c1 : Course | c1 in p1.enrolled implies p1 in Student
}

pred inv1_correct_42[] {
all p : Person, c : Course | p not in Student implies p->c not in enrolled
}

pred inv1_correct_43[] {
enrolled.Course in Student
  all p : Person | p in enrolled.Course implies p in Student
}

pred inv1_correct_44[] {
all x:Course, y:Person-Student | y->x not in enrolled
}

pred inv1_correct_45[] {
all x : Person | x in (Person-Student) implies no x.enrolled
}

pred inv1_correct_46[] {
all p : Person | (some c: Course | p -> c in enrolled) => (p in Student)
}

pred inv1_correct_47[] {
all p: Person | p in enrolled.Course implies p in Student
}

pred inv1_correct_48[] {
all p : univ | p in Person and p not in Student implies all c : univ | c in Course implies p->c not in enrolled
}

pred inv1_correct_49[] {
all x:Person-Student, y:Course | x->y not in enrolled
}

pred inv1_correct_50[] {
all p : enrolled.Course | p in Student
}

pred inv1_correct_51[] {
Course.~enrolled in Student
}

pred inv1_correct_52[] {
all p: (Person-Student) | no p.enrolled
}

pred inv1_correct_53[] {
not some p:Person | some c:Course | p not in Student and p->c in enrolled
}

pred inv1_correct_54[] {
all x: Person | some x.enrolled implies x in Student
}

pred inv1_correct_55[] {
all p:Person | all c1:Course | p->c1 in enrolled implies p in Student
}

pred inv1_correct_56[] {
all p: Person ,c: Course| p in Student or not(p -> c in enrolled)
}

pred inv1_correct_57[] {
all x : Person, y: Course | x->y in enrolled implies x in Student
}

pred inv1_correct_58[] {
all p : Person | all c : Course | p in enrolled.c implies p in Student
}

pred inv1_correct_59[] {
all p:Person | (some c:Course | c in p.enrolled) implies p in Student
}

pred inv1_correct_60[] {
all c: Course, p: Person | c in p.enrolled implies p in Student
}

pred inv1_correct_61[] {
all person: Person | all course: Course | course in person.enrolled implies person in Student
}

pred inv1_correct_62[] {
all x:Person, c:Course | x in enrolled.c implies x in Student
}

pred inv1_correct_63[] {
all x:Course, y:Person-Student | y not in enrolled.x
}

pred inv1_correct_64[] {
all x:Course, y:Person-Student | x not in y.enrolled
}

pred inv1_correct_65[] {
all c: Course, s: Person | c in s.enrolled implies s in Student
}

pred inv1_correct_66[] {
all p: univ | all c: Course | p->c in enrolled implies p in Student
}

pred inv1_correct_67[] {
all c:Course | not some p:Person-Student | p->c in enrolled
}

pred inv1_correct_68[] {
all c : Course, p : Person | enrolled.c in Student
}

pred inv1_correct_69[] {
all p : enrolled.Course | p in Student
	all p: Person | all c: Course | p.enrolled=c implies p in Student
}

pred inv1_correct_70[] {
all p : Person | not no p.enrolled implies p in Student
}

pred inv1_correct_71[] {
all c:Course, p:Person | no (p & Student) implies c not in p.enrolled
}

pred inv1_correct_72[] {
all p:Person, c:Course | p in Student or p->c not in enrolled
}

pred inv1_correct_73[] {
all p : Person | no Course.~enrolled - Student
}

pred inv1_correct_74[] {
all s : Person | all c :  Course | s->c in enrolled implies s in Student
}

pred inv1_correct_75[] {
all p, c : univ | p in Person and p not in Student and c in Course implies p->c not in enrolled
}

pred inv1_correct_76[] {
all a : Person, b : Course | b in a.enrolled implies a in Student
}

