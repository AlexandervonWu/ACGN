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

pred cap002832 { not historically ((inv5 and ((some capBenchR and some CapBenchB) or some capBenchS))) }
pred cap002832c { once (not (inv5 and ((some capBenchR and some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap002832 { cap002832 iff cap002832c }
check CapBenchEquivalent_cap002832 for 4
