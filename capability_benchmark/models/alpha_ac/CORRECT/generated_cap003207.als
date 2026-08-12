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

pred cap003207 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB)) and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS)) }
pred cap003207c { all renamed: CapBenchA | (((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchS) and renamed->renamed in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003207 { cap003207 iff cap003207c }
check CapBenchEquivalent_cap003207 for 4
