module alloy4fun_augmented_coursesOld_inv10
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

pred inv10_oracle[] {
Course.grades.Grade in Student
}

pred inv10_correct_0[] {
grades in Course -> Student -> Grade
}

pred inv10_correct_1[] {
no (Person-Student).(Course.grades)
}

pred inv10_correct_2[] {
all c:Course, p:Person, g:Grade | c->p->g in grades => p in Student
}

pred inv10_correct_3[] {
all p:Person | some p.(Course.grades) implies p in Student
}

pred inv10_correct_4[] {
Course.grades.Grade in Student
  	
  	all p : Person | p in Course.grades.Grade implies p in Student
}

pred inv10_correct_5[] {
all p : Course.grades.Grade | p in Student
}

pred inv10_correct_6[] {
all p : Person - Student , c : Course | p not in c.grades.Grade
}

pred inv10_correct_7[] {
all p: Person, c: Course, g: Grade | (c->p->g) in grades implies p in Student
}

pred inv10_correct_8[] {
all p: Person | p in Course.grades.Grade implies p in Student
}

pred inv10_correct_9[] {
all p:Person| all c:Course| all g:Grade| c->p->g in grades implies p in Student
}

pred inv10_correct_10[] {
no (Person-Student) & Course.grades.Grade
}

pred inv10_correct_11[] {
all s1: Person | all c1: Course | all g1: Grade | (c1->s1->g1 in grades) implies s1 in Student
}

pred inv10_correct_12[] {
all c : Course | all p : Person | all g : Grade | p->g in c.grades implies p in Student
}

pred inv10_correct_13[] {
all c : Course | all p : Person | p in c.grades.Grade implies p in Student
}

pred inv10_correct_14[] {
no Course.grades & (Person-Student)->Grade
}

pred inv10_correct_15[] {
all p : Person | all c : Course | all g : Grade | p->g in c.grades implies p in Student
}

pred inv10_correct_16[] {
all p : Person - Student, c : Course | no ( p->Grade & c.grades )
}

pred inv10_correct_17[] {
all p : Person - Student, c : Course, g : Grade | p->g not in c.grades
}

pred inv10_correct_18[] {
all c : Course | no Grade.~(c.grades) - Student
}

pred inv10_correct_19[] {
all p,c,g : univ | p in Person and c in Course and g in Grade and c->p->g in grades implies p in Student
}

pred inv10_correct_20[] {
all p : Person-Student | p not in Course.grades.Grade
}

pred inv10_correct_21[] {
all p: Person, g: Grade, c: Course | c->p->g in grades implies p in Student
}

pred inv10_correct_22[] {
all c: Course, p: Person, g:Grade | p in c.grades.g implies p in Student
}

pred inv10_correct_23[] {
all p1 : Person | all c1 : Course | all g1 : Grade|
  	(c1->p1->g1 in grades) implies (p1 in Student)
}

pred inv10_correct_24[] {
all c : Course | c.grades.Grade in Student
}

pred inv10_correct_25[] {
Course.grades in Student->Grade
}

pred inv10_correct_26[] {
no Course.grades.Grade - Student
}

pred inv10_correct_27[] {
no Course.grades.Grade & Person-Student
}

pred inv10_correct_28[] {
all p: Person, c: Course | p in c.grades.Grade implies p in Student
}

pred inv10_correct_29[] {
all p: Person, g: Grade | p->g in Course.grades implies p in Student
}

pred inv10_correct_30[] {
all p : Person | p not in Student implies all c : Course, g : Grade | c->p->g not in grades
}

pred inv10_correct_31[] {
all p: Person | all g: Grade | all c: Course| p -> g in c.grades implies
  	p in Student
}

pred inv10_correct_32[] {
all p:Person, c:Course, g:Grade | c in grades.g.p implies p in Student
}

pred inv10_correct_33[] {
all c : Course, p : Person, g : Grade | g in c.grades[p] => p in Student
}

pred inv10_correct_34[] {
all x:Person-Student, y:Course, z:Grade | y->x->z not in grades
}

pred inv10_correct_35[] {
all p:Person,c:Course | c->p in grades.Grade implies p in Student
}

pred inv10_correct_36[] {
all c : Course | all p : Person | all grade : Grade | (p -> grade in c.grades) implies (p in Student)
}

pred inv10_correct_37[] {
all p1 : Person | all c : Course | all g : Grade | c->p1->g in grades implies p1 in Student
}

pred inv10_correct_38[] {
all c: Course | all p: Person | all g: Grade | c->p->g in grades implies p in Student
}

pred inv10_correct_39[] {
all p : Person | all c : Course | p in c.grades.Grade implies p in Student
}

pred inv10_correct_40[] {
all c: Course, p: Person | p in c.grades.Grade implies p in Student
}

pred inv10_correct_41[] {
all person : Person | all course : Course | all grade : Grade |(person->grade in course.grades) implies person in Student
}

pred inv10_correct_42[] {
all c : Course | no (c.grades).Grade - Student
}

pred inv10_correct_43[] {
Grade.~(Course.grades) in Student
}

pred inv10_correct_44[] {
all p : Person, c : Course, g : Grade | (p in c.grades.Grade) implies p in Student
}

pred inv10_correct_45[] {
all p: Person | all g: Grade | all c: Course | c->p->g in grades implies p in Student
}

pred inv10_correct_46[] {
all x : Course | no x.grades & (Person-Student)->Grade
}

pred inv10_correct_47[] {
all p : Person, c : Course, g : Grade | p not in Student implies c->p->g not in grades
}

pred inv10_correct_48[] {
all p: Person, c: Course, g: Grade | p in c.grades.g implies p in Student
}

pred inv10_correct_49[] {
all p : Person | all g : Grade | p->g in Course.grades implies p in Student
}

pred inv10_correct_50[] {
all p : Person, c : Course | some p.(c.grades) implies p in Student
}

