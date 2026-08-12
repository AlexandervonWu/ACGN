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

pred cap005413 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv4 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and some CapBenchB) and some CapBenchB))) }
pred cap005413c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some CapBenchB) and some CapBenchB)) or (not (inv4 and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005413 { cap005413 iff cap005413c }
check CapBenchEquivalent_cap005413 for 4
