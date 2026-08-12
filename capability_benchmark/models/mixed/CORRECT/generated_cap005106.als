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

pred cap005106 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((no CapBenchA and some capBenchS) and some CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR))) }
pred cap005106c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some capBenchR)) or (not (inv1 and ((no CapBenchA and some capBenchS) and some CapBenchB)))) }
assert CapBenchEquivalent_cap005106 { cap005106 iff cap005106c }
check CapBenchEquivalent_cap005106 for 4
