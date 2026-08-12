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

pred cap001774 { ((some x: CapBenchA | x->x in capBenchR) and (inv8 and ((no CapBenchA and no CapBenchA) and some capBenchR))) }
pred cap001774c { (some x: CapBenchA | (x->x in capBenchR and (inv8 and ((no CapBenchA and no CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap001774 { cap001774 iff cap001774c }
check CapBenchEquivalent_cap001774 for 4
