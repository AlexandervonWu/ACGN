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

pred cap003297 { all x: CapBenchA | (x->x in capBenchR and (inv5 and ((some CapBenchB or some capBenchS) or some capBenchR)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003297c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv5 and ((some CapBenchB or some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap003297 { cap003297 iff cap003297c }
check CapBenchEquivalent_cap003297 for 4
