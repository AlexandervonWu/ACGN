sig Person  {
	Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

pred inv15 {
some p,q,r : Person | ((p->q in Tutors and q->r in Tutors) or (q->r in Tutors and r->p in Tutors) or (p->r in Tutors and r->p in Tutors)) implies (p in Teacher or q in Teacher or r in Teacher)
}

pred inv15c {
  all p:Person | some Teacher&(^Tutors).p
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 

