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

pred cap003542 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
pred cap003542c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap003542 { cap003542 iff cap003542c }
check CapBenchEquivalent_cap003542 for 4
