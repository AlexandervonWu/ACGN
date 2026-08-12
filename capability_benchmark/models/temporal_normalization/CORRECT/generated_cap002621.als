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

pred cap002621 { not eventually ((inv4 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
pred cap002621c { always (not (inv4 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap002621 { cap002621 iff cap002621c }
check CapBenchEquivalent_cap002621 for 4
