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

pred cap002135 { ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA)) iff ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) }
pred cap002135c { (((not (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA))) or ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) and ((not ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) or (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap002135 { cap002135 iff cap002135c }
check CapBenchEquivalent_cap002135 for 4
