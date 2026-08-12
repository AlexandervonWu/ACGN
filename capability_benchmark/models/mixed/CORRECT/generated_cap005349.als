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

pred inv15 {
all p:Person | some (^Tutors.p & Teacher)
}

pred inv15c {
  all p:Person | some Teacher&(^Tutors).p
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005349 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv15 and ((some capBenchS or no CapBenchB) or some capBenchS)) and ((no CapBenchA and some CapBenchB) and some CapBenchA))) }
pred cap005349c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some CapBenchB) and some CapBenchA)) or (not (inv15 and ((some capBenchS or no CapBenchB) or some capBenchS)))) }
assert CapBenchEquivalent_cap005349 { cap005349 iff cap005349c }
check CapBenchEquivalent_cap005349 for 4
