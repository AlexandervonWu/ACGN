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

pred cap004635 { not ((inv12 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) }
pred cap004635c { ((not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) or (not (inv12 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004635 { cap004635 iff cap004635c }
check CapBenchEquivalent_cap004635 for 4
