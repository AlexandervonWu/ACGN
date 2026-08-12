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

pred cap003041 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some CapBenchB or some capBenchS) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB)) }
pred cap003041c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB) and renamed->renamed in capBenchR and (inv8 and ((some CapBenchB or some capBenchS) or some CapBenchA))) }
assert CapBenchEquivalent_cap003041 { cap003041 iff cap003041c }
check CapBenchEquivalent_cap003041 for 4
