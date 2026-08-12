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

pred cap004518 { not ((inv1 and ((no CapBenchA and no CapBenchA) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) }
pred cap004518c { ((not ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) or (not (inv1 and ((no CapBenchA and no CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004518 { cap004518 iff cap004518c }
check CapBenchEquivalent_cap004518 for 4
