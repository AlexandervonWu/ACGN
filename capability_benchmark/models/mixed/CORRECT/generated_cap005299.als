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

pred cap005299 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((no CapBenchB or some capBenchS) and some capBenchR)) and ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005299c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and no CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((no CapBenchB or some capBenchS) and some capBenchR)))) }
assert CapBenchEquivalent_cap005299 { cap005299 iff cap005299c }
check CapBenchEquivalent_cap005299 for 4
