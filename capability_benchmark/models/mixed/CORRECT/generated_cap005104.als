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

pred cap005104 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((some CapBenchA and some capBenchS) or some CapBenchB)) and ((some capBenchS or no CapBenchA) or some capBenchR))) }
pred cap005104c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or no CapBenchA) or some capBenchR)) or (not (inv8 and ((some CapBenchA and some capBenchS) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005104 { cap005104 iff cap005104c }
check CapBenchEquivalent_cap005104 for 4
