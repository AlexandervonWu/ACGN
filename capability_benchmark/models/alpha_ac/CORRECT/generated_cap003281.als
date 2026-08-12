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

pred cap003281 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some CapBenchB or no CapBenchB) or some capBenchR)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003281c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv8 and ((some CapBenchB or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap003281 { cap003281 iff cap003281c }
check CapBenchEquivalent_cap003281 for 4
