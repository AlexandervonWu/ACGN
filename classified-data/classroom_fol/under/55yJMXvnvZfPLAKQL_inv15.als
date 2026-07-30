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
all p1 : Person |
  	(p1 in Teacher) or
  	(some t : Teacher | t->p1 in Tutors) or
	(some p2 : Person, t : Teacher | (p2->p1 in Tutors) and (t->p2 in Tutors))
}

pred inv15c {
  all p:Person | some Teacher&(^Tutors).p
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 

