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

pred cap003364 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and some capBenchS) or some capBenchS)) and ((some CapBenchB or no CapBenchB) or some CapBenchA)) }
pred cap003364c { all renamed: CapBenchA | (((some CapBenchB or no CapBenchB) or some CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((some capBenchR and some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap003364 { cap003364 iff cap003364c }
check CapBenchEquivalent_cap003364 for 4
