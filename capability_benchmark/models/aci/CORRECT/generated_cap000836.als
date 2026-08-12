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

pred cap000836 { ((inv12 and ((some CapBenchA and no CapBenchA) or some capBenchS)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB) and ((no CapBenchB or some capBenchS) and no CapBenchA)) }
pred cap000836c { (((no CapBenchB or some capBenchS) and no CapBenchA) and (inv12 and ((some CapBenchA and no CapBenchA) or some capBenchS)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
assert CapBenchEquivalent_cap000836 { cap000836 iff cap000836c }
check CapBenchEquivalent_cap000836 for 4
