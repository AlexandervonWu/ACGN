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

pred inv3 {
no (Teacher & Student)
}

pred inv3c {
 no Student & Teacher 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005491 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and no CapBenchB) or no CapBenchA))) }
pred cap005491c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and no CapBenchB) or no CapBenchA)) or (not (inv3 and ((no CapBenchB or some capBenchS) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005491 { cap005491 iff cap005491c }
check CapBenchEquivalent_cap005491 for 4
