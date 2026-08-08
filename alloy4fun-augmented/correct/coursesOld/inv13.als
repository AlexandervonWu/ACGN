module alloy4fun_augmented_coursesOld_inv13
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

pred inv13_oracle[] {
all c : Course, p : Person | last in p.(c.grades) implies some p.projects & c.projects
}

pred inv13_correct_0[] {
all c : Course | (c.grades).last in projects.(c.projects)
}

pred inv13_correct_1[] {
all c : Course | all n : c.grades.last | some n.projects & c.projects
}

pred inv13_correct_2[] {
all c : Course | c.grades.last in ((c.projects).~(projects))
}

pred inv13_correct_3[] {
all c : Course, s : c.grades.last | some c.projects & s.projects
}

pred inv13_correct_4[] {
all c : Course, s : c.grades.last | some p : c.projects | p in s.projects
}

pred inv13_correct_5[] {
grades.(max[Grade]) in projects.~projects
}

pred inv13_correct_6[] {
all c : Course | last[c.grades] in projects.(c.projects) <: Person
}

pred inv13_correct_7[] {
all c : Course, s : c.grades.last | some s.projects & c.projects
}

pred inv13_correct_8[] {
all c : Course, p : c.grades.last | some p.projects & c.projects
}

pred inv13_correct_9[] {
all c : Course | all s : c.grades.last | some s.projects&c.projects
}

pred inv13_correct_10[] {
all c : Course , n : c.grades.last | some n.projects & c.projects
}

pred inv13_correct_11[] {
all p : Person | all c : Course | p in c.grades.last implies p.projects&c.projects != none
}

pred inv13_correct_12[] {
all c:Course,p:Person | c->p->last in grades implies c->p in projects.~projects
}

pred inv13_correct_13[] {
all c : Course, s : c.grades.(max[Grade]) | some (c.projects & s.projects)
}

