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

pred cap003566 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((no CapBenchA and some CapBenchA) and some CapBenchB))) }
pred cap003566c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((no CapBenchA and some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap003566 { cap003566 iff cap003566c }
check CapBenchEquivalent_cap003566 for 4
