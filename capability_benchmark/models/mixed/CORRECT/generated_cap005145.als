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

pred cap005145 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some CapBenchB or no CapBenchA) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
pred cap005145c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) or (not (inv5 and ((some CapBenchB or no CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005145 { cap005145 iff cap005145c }
check CapBenchEquivalent_cap005145 for 4
