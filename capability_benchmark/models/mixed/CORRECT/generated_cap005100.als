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

pred cap005100 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some capBenchR and some capBenchR) or some CapBenchB)) and ((some CapBenchB or no CapBenchA) or some capBenchR))) }
pred cap005100c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or no CapBenchA) or some capBenchR)) or (not (inv5 and ((some capBenchR and some capBenchR) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005100 { cap005100 iff cap005100c }
check CapBenchEquivalent_cap005100 for 4
