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

pred cap004516 { not ((inv15 and ((some CapBenchA and no CapBenchA) or some CapBenchA)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) }
pred cap004516c { ((not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) or (not (inv15 and ((some CapBenchA and no CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004516 { cap004516 iff cap004516c }
check CapBenchEquivalent_cap004516 for 4
