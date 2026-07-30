module alloy4fun_augmented_classroom_fol_inv15
Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv15_oracle[] {
all p:Person | some Teacher&(^Tutors).p
}

pred inv15_correct_0[] {
all p:Person | some t:Teacher | t in p.^(~Tutors)
}

pred inv15_correct_1[] {
all p1 : Person | some p2, p3 : Person |
  (p2->p1 in Tutors) and ((p2 in Teacher) or
  (p3->p2 in Tutors) and ((p3 in Teacher) or
  (p1->p3 in Tutors) and  (p1 in Teacher)))
}

pred inv15_correct_2[] {
all p : Person | some q,r : Person, t : Teacher | t->p in Tutors or (q->p in Tutors and t->q in Tutors) or (t->r in Tutors and r->q in Tutors and q->p in Tutors)
}

pred inv15_correct_3[] {
all p:Person | some t :Teacher | t in ^Tutors.p
}

pred inv15_correct_4[] {
all p : Person {
  	(some (p.(~Tutors) & Teacher)) or
  	(some (p.(~Tutors).(~Tutors) & Teacher)) or
	(some (p.(~Tutors).(~Tutors).(~Tutors) & Teacher))
  }
}

pred inv15_correct_5[] {
all p1 : Person | some p2, p3 : Person |
  (p2->p1 in Tutors and p2 in Teacher) or
  (p3->p2 in Tutors and p2->p1 in Tutors and p3 in Teacher) or
  (p1->p3 in Tutors and p3->p2 in Tutors and p2->p1 in Tutors and p1 in Teacher)
}

pred inv15_correct_6[] {
all p1 : Person | (some p2 : Teacher | p2 -> p1 in Tutors) or (some p2, p3 : Person | p2 -> p1 in Tutors and p3 -> p2 in Tutors and p3 in Teacher) or (some p2, p3, p4 : Person | p2 -> p1 in Tutors and p3 -> p2 in Tutors and p4 -> p3 in Tutors and p4 in Teacher)
}

