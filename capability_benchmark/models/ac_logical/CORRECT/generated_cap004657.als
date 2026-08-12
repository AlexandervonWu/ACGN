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

pred cap004657 { not ((inv1 and ((some capBenchS or no CapBenchB) or no CapBenchA)) and ((no CapBenchA and some CapBenchB) and some capBenchS)) }
pred cap004657c { ((not ((no CapBenchA and some CapBenchB) and some capBenchS)) or (not (inv1 and ((some capBenchS or no CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004657 { cap004657 iff cap004657c }
check CapBenchEquivalent_cap004657 for 4
