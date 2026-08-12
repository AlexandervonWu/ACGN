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

pred cap004569 { not ((inv1 and ((some capBenchS or some CapBenchA) or some CapBenchB)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) }
pred cap004569c { ((not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) or (not (inv1 and ((some capBenchS or some CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004569 { cap004569 iff cap004569c }
check CapBenchEquivalent_cap004569 for 4
