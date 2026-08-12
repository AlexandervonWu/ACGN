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

pred inv1 {
Person = Student
}

pred inv1c {
  Person in Student
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003251 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) and ((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003251c { all renamed: CapBenchA | (((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003251 { cap003251 iff cap003251c }
check CapBenchEquivalent_cap003251 for 4
