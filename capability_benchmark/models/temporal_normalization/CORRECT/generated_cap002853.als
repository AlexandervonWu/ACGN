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

pred cap002853 { not (((inv4 and ((some CapBenchB or some capBenchR) or some capBenchS))) since (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA))) }
pred cap002853c { ((not (inv4 and ((some CapBenchB or some capBenchR) or some capBenchS))) triggered (not ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap002853 { cap002853 iff cap002853c }
check CapBenchEquivalent_cap002853 for 4
