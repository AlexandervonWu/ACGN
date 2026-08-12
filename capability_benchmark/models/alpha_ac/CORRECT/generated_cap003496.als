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

pred cap003496 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or no CapBenchB) or no CapBenchA)) }
pred cap003496c { all renamed: CapBenchA | (((some capBenchS or no CapBenchB) or no CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003496 { cap003496 iff cap003496c }
check CapBenchEquivalent_cap003496 for 4
