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

pred cap003330 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((no CapBenchA and some CapBenchB) and some capBenchS)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003330c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv5 and ((no CapBenchA and some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap003330 { cap003330 iff cap003330c }
check CapBenchEquivalent_cap003330 for 4
