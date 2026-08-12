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

pred cap003342 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS)) and ((no CapBenchB or some CapBenchA) and some CapBenchA)) }
pred cap003342c { all renamed: CapBenchA | (((no CapBenchB or some CapBenchA) and some CapBenchA) and renamed->renamed in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap003342 { cap003342 iff cap003342c }
check CapBenchEquivalent_cap003342 for 4
