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

pred cap004108 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((some capBenchR and some capBenchS) or some CapBenchB))) }
pred cap004108c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((some capBenchR and some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap004108 { cap004108 iff cap004108c }
check CapBenchEquivalent_cap004108 for 4
