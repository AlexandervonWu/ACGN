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

pred cap000279 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv12 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR))) }
pred cap000279c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv12 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap000279 { cap000279 iff cap000279c }
check CapBenchEquivalent_cap000279 for 4
