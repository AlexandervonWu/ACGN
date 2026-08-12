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

pred cap005448 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or some capBenchS) or some CapBenchB))) }
pred cap005448c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some capBenchS) or some CapBenchB)) or (not (inv5 and ((some CapBenchA and some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005448 { cap005448 iff cap005448c }
check CapBenchEquivalent_cap005448 for 4
