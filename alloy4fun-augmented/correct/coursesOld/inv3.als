module alloy4fun_augmented_coursesOld_inv3
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

pred inv3_oracle[] {
teaches in Person some -> Course
}

pred inv3_correct_0[] {
all c : Course | some teaches.c
}

pred inv3_correct_1[] {
Course = Person.teaches
}

pred inv3_correct_2[] {
all c : Course | some p : Person | p->c in teaches
}

pred inv3_correct_3[] {
Course in Person.teaches
}

pred inv3_correct_4[] {
all c: Course | some (c & Person.teaches)
}

pred inv3_correct_5[] {
all c: Course | some p: Person | c in p.teaches
}

pred inv3_correct_6[] {
Person.teaches = Course
}

pred inv3_correct_7[] {
all c: Course | some c.~teaches
}

pred inv3_correct_8[] {
all x:Course | some teaches.x
}

pred inv3_correct_9[] {
Course = Course & Person.teaches
}

pred inv3_correct_10[] {
all c: Course | c in Person.teaches
}

pred inv3_correct_11[] {
all c: Course | c.~teaches not in none
}

pred inv3_correct_12[] {
all c : univ | c in Course implies some p : univ | p in Person and p->c in teaches
}

pred inv3_correct_13[] {
all c : Course | teaches.c != none
}

pred inv3_correct_14[] {
all c: Course | not no teaches.c
}

pred inv3_correct_15[] {
Course & Person.teaches = Course
}

pred inv3_correct_16[] {
Person.teaches in Course and Course in Person.teaches
}

pred inv3_correct_17[] {
Person.teaches & Course = Course
}

pred inv3_correct_18[] {
all course : Course | course in Person.teaches
}

pred inv3_correct_19[] {
no (Course - Person.teaches)
}

pred inv3_correct_20[] {
no c:Course | no teaches.c
}

pred inv3_correct_21[] {
all x : univ | x in Course implies (some y : univ | y->x in teaches)
}

pred inv3_correct_22[] {
all x : Course | some y : Person | y->x in teaches
}

pred inv3_correct_23[] {
all c: Course | one (c & Person.teaches)
}

pred inv3_correct_24[] {
all kurs: Course | kurs in Person.teaches
}

