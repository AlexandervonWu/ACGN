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

pred inv13 {
Tutors in (Teacher->Student)
}

pred inv13c {
  Tutors in Teacher -> Student
}

check correct { inv13 <=> inv13c}
pred under { inv13 and !inv13c}
pred over { !inv13 and inv13c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005042 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv13 and ((no CapBenchA and some capBenchS) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB))) }
pred cap005042c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchB)) or (not (inv13 and ((no CapBenchA and some capBenchS) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005042 { cap005042 iff cap005042c }
check CapBenchEquivalent_cap005042 for 4
