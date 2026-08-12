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

pred cap004906 { not ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchB or some CapBenchA) and some CapBenchB)) }
pred cap004906c { ((not ((no CapBenchB or some CapBenchA) and some CapBenchB)) or (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004906 { cap004906 iff cap004906c }
check CapBenchEquivalent_cap004906 for 4
