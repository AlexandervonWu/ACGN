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

pred cap003539 { all x, y: CapBenchA | (x->y in capBenchR and (inv12 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA))) }
pred cap003539c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv12 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap003539 { cap003539 iff cap003539c }
check CapBenchEquivalent_cap003539 for 4
