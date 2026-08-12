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

pred cap002099 { ((inv1 and ((no CapBenchB or some capBenchR) and some CapBenchB)) iff ((some CapBenchA and no CapBenchA) or some capBenchR)) }
pred cap002099c { (((not (inv1 and ((no CapBenchB or some capBenchR) and some CapBenchB))) or ((some CapBenchA and no CapBenchA) or some capBenchR)) and ((not ((some CapBenchA and no CapBenchA) or some capBenchR)) or (inv1 and ((no CapBenchB or some capBenchR) and some CapBenchB)))) }
assert CapBenchEquivalent_cap002099 { cap002099 iff cap002099c }
check CapBenchEquivalent_cap002099 for 4
