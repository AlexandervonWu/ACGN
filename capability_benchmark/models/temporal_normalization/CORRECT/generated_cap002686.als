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

pred cap002686 { not always ((inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
pred cap002686c { eventually (not (inv2 and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap002686 { cap002686 iff cap002686c }
check CapBenchEquivalent_cap002686 for 4
