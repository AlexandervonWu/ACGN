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
all x: Person | x in Student implies x not in Teacher
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

pred cap003627 { all x, y: CapBenchA | (x->y in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
pred cap003627c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap003627 { cap003627 iff cap003627c }
check CapBenchEquivalent_cap003627 for 4
