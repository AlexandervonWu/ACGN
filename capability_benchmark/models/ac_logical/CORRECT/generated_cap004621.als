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

pred cap004621 { not ((inv5 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR)) }
pred cap004621c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchR)) or (not (inv5 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004621 { cap004621 iff cap004621c }
check CapBenchEquivalent_cap004621 for 4
