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

pred cap003223 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB)) and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003223c { all renamed: CapBenchA | (((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003223 { cap003223 iff cap003223c }
check CapBenchEquivalent_cap003223 for 4
