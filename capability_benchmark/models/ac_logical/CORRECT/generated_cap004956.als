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

pred inv2 {
no Teacher
}

pred inv2c {
  no Teacher
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004956 { not ((inv2 and ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) }
pred cap004956c { ((not ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) or (not (inv2 and ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004956 { cap004956 iff cap004956c }
check CapBenchEquivalent_cap004956 for 4
