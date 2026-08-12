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
all p:Person | some t:Teacher | t in p.^(~Tutors)
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

pred cap005256 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv15 and ((some CapBenchA and some CapBenchA) or some capBenchR)) and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005256c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv15 and ((some CapBenchA and some CapBenchA) or some capBenchR)))) }
assert CapBenchEquivalent_cap005256 { cap005256 iff cap005256c }
check CapBenchEquivalent_cap005256 for 4
