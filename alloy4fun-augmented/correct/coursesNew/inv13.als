module alloy4fun_augmented_coursesNew_inv13
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
grades.(max[Grade]) in projects.~projects
}

pred inv13_correct_1[] {
all c : Course | all p : Person | all g : Grade | ((g = max[Grade]) and p->g in c.grades) implies ((c.projects & p.projects) != none)
}

