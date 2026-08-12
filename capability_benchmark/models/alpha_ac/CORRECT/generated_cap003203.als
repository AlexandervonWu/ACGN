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

pred inv5 {
some c : Class | some x : Teacher | x->c in Teaches
}

pred inv5c {
  some Teacher.Teaches
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003203 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchB or some CapBenchB) and no CapBenchB)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) }
pred cap003203c { all renamed: CapBenchA | (((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS) and renamed->renamed in capBenchR and (inv5 and ((no CapBenchB or some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003203 { cap003203 iff cap003203c }
check CapBenchEquivalent_cap003203 for 4
