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

pred cap004396 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap004396c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((some capBenchR and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap004396 { cap004396 iff cap004396c }
check CapBenchEquivalent_cap004396 for 4
