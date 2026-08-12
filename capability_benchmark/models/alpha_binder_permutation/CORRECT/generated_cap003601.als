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

pred inv15 {
all p:Person | some (^Tutors.p & Teacher)
}

pred inv15c {
  all p:Person | some Teacher&(^Tutors).p
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003601 { all x, y: CapBenchA | (x->y in capBenchR and (inv15 and ((some capBenchS or some capBenchR) or some CapBenchB))) }
pred cap003601c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv15 and ((some capBenchS or some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap003601 { cap003601 iff cap003601c }
check CapBenchEquivalent_cap003601 for 4
