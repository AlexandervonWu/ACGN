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
all t : Teacher | all c1, c2 : Class | t->c1 in Teaches and t->c2 in Teaches implies c1 = c2
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

pred cap003507 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA))) }
pred cap003507c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap003507 { cap003507 iff cap003507c }
check CapBenchEquivalent_cap003507 for 4
