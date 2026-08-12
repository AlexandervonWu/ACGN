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

pred cap000813 { ((inv5 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) or ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and CapBenchA in CapBenchA + CapBenchB) or ((some capBenchR and no CapBenchA) or no CapBenchA)) }
pred cap000813c { (((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and CapBenchA in CapBenchA + CapBenchB) or ((some capBenchR and no CapBenchA) or no CapBenchA) or (inv5 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000813 { cap000813 iff cap000813c }
check CapBenchEquivalent_cap000813 for 4
