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
some Teacher.Teaches
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

pred cap004276 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv5 and ((some capBenchR and no CapBenchA) or some capBenchR))) }
pred cap004276c { some a, b: CapBenchA | (b->a in capBenchR and (inv5 and ((some capBenchR and no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap004276 { cap004276 iff cap004276c }
check CapBenchEquivalent_cap004276 for 4
