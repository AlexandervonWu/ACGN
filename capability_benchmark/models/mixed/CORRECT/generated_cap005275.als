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

pred cap005275 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv13 and ((no CapBenchB or no CapBenchA) and some capBenchR)) and ((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005275c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv13 and ((no CapBenchB or no CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap005275 { cap005275 iff cap005275c }
check CapBenchEquivalent_cap005275 for 4
