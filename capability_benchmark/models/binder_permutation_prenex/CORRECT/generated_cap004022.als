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

pred cap004022 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA))) }
pred cap004022c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap004022 { cap004022 iff cap004022c }
check CapBenchEquivalent_cap004022 for 4
