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

pred cap002595 { not (((inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB))) since (((some capBenchR and some CapBenchB) or some capBenchR))) }
pred cap002595c { ((not (inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some CapBenchB))) triggered (not ((some capBenchR and some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002595 { cap002595 iff cap002595c }
check CapBenchEquivalent_cap002595 for 4
