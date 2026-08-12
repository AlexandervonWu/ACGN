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

pred cap005060 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv12 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) and ((some CapBenchB or some capBenchS) or no CapBenchB))) }
pred cap005060c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some capBenchS) or no CapBenchB)) or (not (inv12 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005060 { cap005060 iff cap005060c }
check CapBenchEquivalent_cap005060 for 4
