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
all disj t: Teacher | lone t.Teaches
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

pred cap004399 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004399c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004399 { cap004399 iff cap004399c }
check CapBenchEquivalent_cap004399 for 4
