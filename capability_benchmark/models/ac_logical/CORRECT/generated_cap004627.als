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

pred inv15 {
all p:Person | some t:Teacher | t in p.^(~Tutors)
}

pred inv15c {
  all p:Person | some Teacher&(^Tutors).p
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004627 { not ((inv15 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)) and ((some capBenchR and some capBenchS) or some capBenchR)) }
pred cap004627c { ((not ((some capBenchR and some capBenchS) or some capBenchR)) or (not (inv15 and ((CapBenchA in CapBenchA + CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004627 { cap004627 iff cap004627c }
check CapBenchEquivalent_cap004627 for 4
