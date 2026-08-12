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

pred cap003526 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((no CapBenchA and no CapBenchB) and some CapBenchA))) }
pred cap003526c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((no CapBenchA and no CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003526 { cap003526 iff cap003526c }
check CapBenchEquivalent_cap003526 for 4
