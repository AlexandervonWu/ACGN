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

pred cap004043 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((no CapBenchB or some capBenchS) and some CapBenchA))) }
pred cap004043c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((no CapBenchB or some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap004043 { cap004043 iff cap004043c }
check CapBenchEquivalent_cap004043 for 4
