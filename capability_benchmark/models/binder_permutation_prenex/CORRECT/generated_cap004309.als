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

pred cap004309 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv5 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
pred cap004309c { some a, b: CapBenchA | (b->a in capBenchR and (inv5 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
assert CapBenchEquivalent_cap004309 { cap004309 iff cap004309c }
check CapBenchEquivalent_cap004309 for 4
