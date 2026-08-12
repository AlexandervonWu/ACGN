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

pred cap003287 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR)) and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003287c { all renamed: CapBenchA | (((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003287 { cap003287 iff cap003287c }
check CapBenchEquivalent_cap003287 for 4
