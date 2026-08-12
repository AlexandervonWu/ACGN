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

pred cap004071 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv15 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB))) }
pred cap004071c { some a, b: CapBenchA | (b->a in capBenchR and (inv15 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap004071 { cap004071 iff cap004071c }
check CapBenchEquivalent_cap004071 for 4
