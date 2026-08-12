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

pred cap001757 { ((all x: CapBenchA | x->x in capBenchR) or (inv4 and ((some CapBenchB or some CapBenchA) or some capBenchR))) }
pred cap001757c { (all x: CapBenchA | (x->x in capBenchR or (inv4 and ((some CapBenchB or some CapBenchA) or some capBenchR)))) }
assert CapBenchEquivalent_cap001757 { cap001757 iff cap001757c }
check CapBenchEquivalent_cap001757 for 4
