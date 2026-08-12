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

pred cap002240 { not not ((inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
pred cap002240c { (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) }
assert CapBenchEquivalent_cap002240 { cap002240 iff cap002240c }
check CapBenchEquivalent_cap002240 for 4
