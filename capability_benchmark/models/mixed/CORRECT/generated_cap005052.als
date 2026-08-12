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

pred cap005052 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv5 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) and ((some CapBenchB or some capBenchR) or no CapBenchB))) }
pred cap005052c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some capBenchR) or no CapBenchB)) or (not (inv5 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005052 { cap005052 iff cap005052c }
check CapBenchEquivalent_cap005052 for 4
