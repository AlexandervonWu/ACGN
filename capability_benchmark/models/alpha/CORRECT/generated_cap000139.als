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

pred cap000139 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv8 and ((no CapBenchB or some CapBenchB) and no CapBenchA))) }
pred cap000139c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv8 and ((no CapBenchB or some CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap000139 { cap000139 iff cap000139c }
check CapBenchEquivalent_cap000139 for 4
