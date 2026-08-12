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

pred cap000135 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA))) }
pred cap000135c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap000135 { cap000135 iff cap000135c }
check CapBenchEquivalent_cap000135 for 4
