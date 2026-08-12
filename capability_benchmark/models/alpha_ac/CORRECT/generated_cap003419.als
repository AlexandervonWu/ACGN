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

pred cap003419 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and no CapBenchA) or some CapBenchB)) }
pred cap003419c { all renamed: CapBenchA | (((some CapBenchA and no CapBenchA) or some CapBenchB) and renamed->renamed in capBenchR and (inv8 and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003419 { cap003419 iff cap003419c }
check CapBenchEquivalent_cap003419 for 4
