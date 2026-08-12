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

pred cap002026 { ((inv1 and ((no CapBenchA and no CapBenchB) and some CapBenchA)) implies ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB)) }
pred cap002026c { ((not (inv1 and ((no CapBenchA and no CapBenchB) and some CapBenchA))) or ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB)) }
assert CapBenchEquivalent_cap002026 { cap002026 iff cap002026c }
check CapBenchEquivalent_cap002026 for 4
