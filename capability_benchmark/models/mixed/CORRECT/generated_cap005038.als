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
all t:Teacher, c1,c2:Class | (t -> c1 in Teaches) and (t -> c2 in Teaches) implies c1 = c2
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

pred cap005038 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA)) and ((no CapBenchB or no CapBenchA) and no CapBenchB))) }
pred cap005038c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or no CapBenchA) and no CapBenchB)) or (not (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005038 { cap005038 iff cap005038c }
check CapBenchEquivalent_cap005038 for 4
