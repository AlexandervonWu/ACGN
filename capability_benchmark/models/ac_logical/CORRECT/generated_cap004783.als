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

pred cap004783 { not ((inv2 and ((no CapBenchB or no CapBenchB) and some capBenchR)) and ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004783c { ((not ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv2 and ((no CapBenchB or no CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap004783 { cap004783 iff cap004783c }
check CapBenchEquivalent_cap004783 for 4
