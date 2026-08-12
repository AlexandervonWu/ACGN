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

pred cap004865 { not ((inv15 and ((some capBenchS or some capBenchS) or some capBenchS)) and ((no CapBenchA and no CapBenchB) and some CapBenchA)) }
pred cap004865c { ((not ((no CapBenchA and no CapBenchB) and some CapBenchA)) or (not (inv15 and ((some capBenchS or some capBenchS) or some capBenchS)))) }
assert CapBenchEquivalent_cap004865 { cap004865 iff cap004865c }
check CapBenchEquivalent_cap004865 for 4
