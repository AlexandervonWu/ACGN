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
all p:Person | p not in Teacher
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

pred cap002402 { not not ((inv2 and ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002402c { (inv2 and ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap002402 { cap002402 iff cap002402c }
check CapBenchEquivalent_cap002402 for 4
