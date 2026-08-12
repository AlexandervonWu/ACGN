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

pred cap005018 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((no CapBenchA and no CapBenchA) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
pred cap005018c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) or (not (inv8 and ((no CapBenchA and no CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005018 { cap005018 iff cap005018c }
check CapBenchEquivalent_cap005018 for 4
