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

pred cap003842 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS))) }
pred cap003842c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some capBenchS))) }
assert CapBenchEquivalent_cap003842 { cap003842 iff cap003842c }
check CapBenchEquivalent_cap003842 for 4
