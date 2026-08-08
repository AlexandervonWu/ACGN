module alloy4fun_augmented_coursesNew_inv3
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
all c:Course| some teaches.c
}

pred inv3_correct_1[] {
all c: Course | #c.~teaches>0
}

pred inv3_correct_2[] {
all c : Course | some p : Person | c in p.teaches
}

pred inv3_correct_3[] {
all c: Course | c in Person.teaches
}

pred inv3_correct_4[] {
all x: Course | some teaches.x
}

pred inv3_correct_5[] {
all x : Course | some y : Person | y in teaches.x
}

pred inv3_correct_6[] {
Course = Person.teaches
}

pred inv3_correct_7[] {
all x : Course | some y : Person | x in y.teaches
}

pred inv3_correct_8[] {
all c1: Course | some p1 : Person | p1->c1 in teaches
}

pred inv3_correct_9[] {
all c: Course | #(teaches.c)>0
}

pred inv3_correct_10[] {
all x:Course| some z:Person | z->x in teaches
}

pred inv3_correct_11[] {
all y: Course | #y.~teaches>0
}

pred inv3_correct_12[] {
all c:Course | some t:Person | c in t.teaches
}

pred inv3_correct_13[] {
all course : Course | course in Person.teaches
}

pred inv3_correct_14[] {
all c : Course | some (c.(~teaches))
}

pred inv3_correct_15[] {
all x : Course | #(teaches.x)>0
}

pred inv3_correct_16[] {
all c:Course | some teacher:Person | c in teacher.teaches
}

pred inv3_correct_17[] {
no c : Course | c.~teaches=none
}

pred inv3_correct_18[] {
all c:Course| some u:Person| u->c in teaches
}

pred inv3_correct_19[] {
all c : Course | c.~(teaches)!=none
}

pred inv3_correct_20[] {
all c : Course | teaches.c != none
}

