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

pred cap003164 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and some capBenchR) or no CapBenchA)) and ((some CapBenchB or no CapBenchA) or some capBenchS)) }
pred cap003164c { all renamed: CapBenchA | (((some CapBenchB or no CapBenchA) or some capBenchS) and renamed->renamed in capBenchR and (inv4 and ((some capBenchR and some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap003164 { cap003164 iff cap003164c }
check CapBenchEquivalent_cap003164 for 4
