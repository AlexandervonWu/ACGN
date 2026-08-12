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

pred cap003552 { all x, y: CapBenchA | (x->y in capBenchR and (inv5 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap003552c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv5 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap003552 { cap003552 iff cap003552c }
check CapBenchEquivalent_cap003552 for 4
