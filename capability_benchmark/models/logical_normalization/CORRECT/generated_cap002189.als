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
all p : Person | p not in Teacher
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

pred cap002189 { ((inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) iff ((no CapBenchA and some capBenchS) and some capBenchS)) }
pred cap002189c { (((not (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) or ((no CapBenchA and some capBenchS) and some capBenchS)) and ((not ((no CapBenchA and some capBenchS) and some capBenchS)) or (inv2 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap002189 { cap002189 iff cap002189c }
check CapBenchEquivalent_cap002189 for 4
