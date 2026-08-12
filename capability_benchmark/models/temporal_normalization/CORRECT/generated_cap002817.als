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

pred cap002817 { not (((inv5 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) since (((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002817c { ((not (inv5 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) triggered (not ((no CapBenchA and some capBenchS) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002817 { cap002817 iff cap002817c }
check CapBenchEquivalent_cap002817 for 4
