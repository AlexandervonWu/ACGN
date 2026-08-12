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

pred cap004722 { not ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB)) and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004722c { ((not ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004722 { cap004722 iff cap004722c }
check CapBenchEquivalent_cap004722 for 4
