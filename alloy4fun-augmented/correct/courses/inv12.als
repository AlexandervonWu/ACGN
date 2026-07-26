module alloy4fun_augmented_courses_inv12
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

pred inv12_oracle[] {
all p : Person, c : Course | lone p.(c.grades)
}

pred inv12_correct_0[] {
all c: Course | (all p: Person| lone g: Grade | p->g in c.grades)
}

pred inv12_correct_1[] {
all c: Course , p: Person| lone g: Grade | p->g in c.grades
}

pred inv12_correct_2[] {
all s : Person, c : Course | lone g : Grade | s->g in c.grades
}

pred inv12_correct_3[] {
all c: Course, p:Person| lone p.(c.grades)
}

pred inv12_correct_4[] {
all course:Course | (all p:Person | lone g:Grade | p->g in course.grades)
}

pred inv12_correct_5[] {
all p:Person, c:Course | lone g:Grade | c->p->g in grades
}

pred inv12_correct_6[] {
all x : Person | all y : Course | lone x.(y.grades)
  all p : Person, c : Course | lone p.(c.grades)
}

pred inv12_correct_7[] {
all c : Course, p : Person | ( all g1,g2 : Grade | p->g1 in c.grades and p->g2 in c.grades implies g1 = g2 )
}

pred inv12_correct_8[] {
all x:Person, c:Course, g,u:Grade| c->x->g in grades and c->x->u in grades implies g=u
}

pred inv12_correct_9[] {
all x : Person | all y : Course | lone y.grades[x]
}

pred inv12_correct_10[] {
all p:Person,c:Course|lone g:Grade|  p->g in c.grades
}

pred inv12_correct_11[] {
all u:Person, c:Course, g,x:Grade| c->u->g in grades and c->u->x in grades implies g=x
}

