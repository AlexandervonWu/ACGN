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

pred cap001860 { ((some x: CapBenchA | x->x in capBenchR) and (inv15 and ((some CapBenchA and some capBenchS) or some capBenchS))) }
pred cap001860c { (some x: CapBenchA | (x->x in capBenchR and (inv15 and ((some CapBenchA and some capBenchS) or some capBenchS)))) }
assert CapBenchEquivalent_cap001860 { cap001860 iff cap001860c }
check CapBenchEquivalent_cap001860 for 4
