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
some Teacher.Teaches
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

pred cap003634 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchA))) }
pred cap003634c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap003634 { cap003634 iff cap003634c }
check CapBenchEquivalent_cap003634 for 4
