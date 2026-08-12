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

pred cap005177 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS))) }
pred cap005177c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchS)) or (not (inv4 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005177 { cap005177 iff cap005177c }
check CapBenchEquivalent_cap005177 for 4
