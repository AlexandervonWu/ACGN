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
all p:Person | p in Student
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

pred cap004583 { not ((inv1 and ((no CapBenchB or no CapBenchA) and some CapBenchB)) and ((some CapBenchA and some CapBenchA) or some capBenchR)) }
pred cap004583c { ((not ((some CapBenchA and some CapBenchA) or some capBenchR)) or (not (inv1 and ((no CapBenchB or no CapBenchA) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004583 { cap004583 iff cap004583c }
check CapBenchEquivalent_cap004583 for 4
