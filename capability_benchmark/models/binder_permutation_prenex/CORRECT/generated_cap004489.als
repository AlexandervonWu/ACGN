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

pred cap004489 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap004489c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some CapBenchB or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004489 { cap004489 iff cap004489c }
check CapBenchEquivalent_cap004489 for 4
