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

pred inv1 {
Person = Student
}

pred inv1c {
  Person in Student
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000831 { ((inv1 and ((no CapBenchB or some CapBenchB) and some capBenchS)) or ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA)) }
pred cap000831c { (((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or CapBenchA in CapBenchA + CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA) or (inv1 and ((no CapBenchB or some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap000831 { cap000831 iff cap000831c }
check CapBenchEquivalent_cap000831 for 4
