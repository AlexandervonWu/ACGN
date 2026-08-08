module alloy4fun_augmented_coursesNew_inv9
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

pred inv9_oracle[] {
all p : Person | no (p.teaches.~teaches - p) & p.teaches.~enrolled
}

pred inv9_correct_0[] {
all c : Course | all p : teaches.c | no p.teaches & ((teaches.c - p).enrolled)
}

pred inv9_correct_1[] {
all disj p1, p2: Person | some (p2.teaches & p1.teaches) => (#(p1.enrolled & p2.teaches)=0)
}

pred inv9_correct_2[] {
all p1,p2 : Person | all c1,c2 : Course | 
  (p1!=p2 and c1 in p1.teaches and c1 in p2.teaches) implies  
  ((c2 in p1.enrolled implies c2 not in p2.teaches) and (c2 in p2.enrolled implies c2 not in p1.teaches))
}

