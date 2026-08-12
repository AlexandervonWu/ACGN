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

pred inv7 {
Class in Teacher.Teaches
}

pred inv7c {
  all c:Class | some Teacher&Teaches.c
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003597 { all x, y: CapBenchA | (x->y in capBenchR and (inv7 and ((some CapBenchB or some capBenchR) or some CapBenchB))) }
pred cap003597c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv7 and ((some CapBenchB or some capBenchR) or some CapBenchB))) }
assert CapBenchEquivalent_cap003597 { cap003597 iff cap003597c }
check CapBenchEquivalent_cap003597 for 4
