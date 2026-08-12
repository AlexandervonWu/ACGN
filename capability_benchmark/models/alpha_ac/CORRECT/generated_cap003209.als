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
all p: Person | p in Teacher or p in Student
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

pred cap003209 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchB or no CapBenchA) or no CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) }
pred cap003209c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchS) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchB or no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap003209 { cap003209 iff cap003209c }
check CapBenchEquivalent_cap003209 for 4
