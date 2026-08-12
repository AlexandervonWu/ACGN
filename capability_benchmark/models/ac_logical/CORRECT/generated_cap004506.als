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

pred cap004506 { not ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) }
pred cap004506c { ((not ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) or (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap004506 { cap004506 iff cap004506c }
check CapBenchEquivalent_cap004506 for 4
