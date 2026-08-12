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

pred inv4 {
no ((Person-Student)-Teacher)
}

pred inv4c {
 Person in Student + Teacher
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003830 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchA and some CapBenchB) and some capBenchS))) }
pred cap003830c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((no CapBenchA and some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap003830 { cap003830 iff cap003830c }
check CapBenchEquivalent_cap003830 for 4
