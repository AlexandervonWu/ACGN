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

pred cap003003 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchB or some CapBenchA) and some CapBenchA)) and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) }
pred cap003003c { all renamed: CapBenchA | (((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((no CapBenchB or some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap003003 { cap003003 iff cap003003c }
check CapBenchEquivalent_cap003003 for 4
