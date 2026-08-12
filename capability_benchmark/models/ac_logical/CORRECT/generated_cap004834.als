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

pred cap004834 { not ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap004834c { ((not ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) or (not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap004834 { cap004834 iff cap004834c }
check CapBenchEquivalent_cap004834 for 4
