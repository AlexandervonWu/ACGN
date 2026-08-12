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

pred inv8 {
all t:Teacher | lone t.Teaches
}

pred inv8c {
  all t:Teacher | lone t.Teaches
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003608 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((some capBenchR and some capBenchS) or some CapBenchB))) }
pred cap003608c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((some capBenchR and some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap003608 { cap003608 iff cap003608c }
check CapBenchEquivalent_cap003608 for 4
