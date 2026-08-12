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

pred inv5 {
some c : Class | some x : Teacher | x->c in Teaches
}

pred inv5c {
  some Teacher.Teaches
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000261 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv5 and ((some capBenchS or some CapBenchA) or some capBenchR))) }
pred cap000261c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv5 and ((some capBenchS or some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap000261 { cap000261 iff cap000261c }
check CapBenchEquivalent_cap000261 for 4
