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

pred cap003154 { all x: CapBenchA | (x->x in capBenchR and (inv15 and ((no CapBenchA and no CapBenchB) and no CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS)) }
pred cap003154c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some capBenchS) and renamed->renamed in capBenchR and (inv15 and ((no CapBenchA and no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap003154 { cap003154 iff cap003154c }
check CapBenchEquivalent_cap003154 for 4
