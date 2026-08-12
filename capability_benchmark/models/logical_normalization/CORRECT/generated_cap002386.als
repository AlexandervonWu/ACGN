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

pred cap002386 { ((inv4 and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) implies ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA)) }
pred cap002386c { ((not (inv4 and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) or ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and some CapBenchA)) }
assert CapBenchEquivalent_cap002386 { cap002386 iff cap002386c }
check CapBenchEquivalent_cap002386 for 4
