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

pred cap004164 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv4 and ((some capBenchR and some capBenchR) or no CapBenchA))) }
pred cap004164c { some a, b: CapBenchA | (b->a in capBenchR and (inv4 and ((some capBenchR and some capBenchR) or no CapBenchA))) }
assert CapBenchEquivalent_cap004164 { cap004164 iff cap004164c }
check CapBenchEquivalent_cap004164 for 4
