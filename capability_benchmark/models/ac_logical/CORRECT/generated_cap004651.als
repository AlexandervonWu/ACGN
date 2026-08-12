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

pred cap004651 { not ((inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA)) and ((some capBenchR and some CapBenchA) or some capBenchS)) }
pred cap004651c { ((not ((some capBenchR and some CapBenchA) or some capBenchS)) or (not (inv5 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004651 { cap004651 iff cap004651c }
check CapBenchEquivalent_cap004651 for 4
