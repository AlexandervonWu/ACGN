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

pred cap005105 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchB or some capBenchS) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR))) }
pred cap005105c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchR)) or (not (inv1 and ((some CapBenchB or some capBenchS) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005105 { cap005105 iff cap005105c }
check CapBenchEquivalent_cap005105 for 4
