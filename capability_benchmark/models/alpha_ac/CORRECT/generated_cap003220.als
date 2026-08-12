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

pred cap003220 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and no CapBenchB) or no CapBenchB)) and ((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003220c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv4 and ((some capBenchR and no CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003220 { cap003220 iff cap003220c }
check CapBenchEquivalent_cap003220 for 4
