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

pred cap003696 { all x, y: CapBenchA | (x->y in capBenchR and (inv15 and ((some capBenchR and some CapBenchA) or no CapBenchB))) }
pred cap003696c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv15 and ((some capBenchR and some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap003696 { cap003696 iff cap003696c }
check CapBenchEquivalent_cap003696 for 4
