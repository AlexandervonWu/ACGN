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

pred inv12 {
Teaches.Groups.Group.Person & Teacher = Teacher
}

pred inv12c {
 all x:Teacher | some x.Teaches.Groups
}

check correct { inv12 <=> inv12c}
pred under { inv12 and !inv12c}
pred over { !inv12 and inv12c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004004 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv12 and ((some capBenchR and some CapBenchA) or some CapBenchA))) }
pred cap004004c { some a, b: CapBenchA | (b->a in capBenchR and (inv12 and ((some capBenchR and some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap004004 { cap004004 iff cap004004c }
check CapBenchEquivalent_cap004004 for 4
