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

pred cap002172 { not (all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some capBenchR and some capBenchS) or no CapBenchA)))) }
pred cap002172c { some x: CapBenchA | not (x->x in capBenchR and (inv8 and ((some capBenchR and some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap002172 { cap002172 iff cap002172c }
check CapBenchEquivalent_cap002172 for 4
