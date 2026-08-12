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

pred cap001290 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((no CapBenchA and some capBenchR) and some capBenchR))) }
pred cap001290c { all a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((no CapBenchA and some capBenchR) and some capBenchR))) }
assert CapBenchEquivalent_cap001290 { cap001290 iff cap001290c }
check CapBenchEquivalent_cap001290 for 4
