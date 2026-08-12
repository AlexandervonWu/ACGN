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

pred cap000722 { ((inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB)) and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) }
pred cap000722c { (((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA) and (inv2 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB)) and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
assert CapBenchEquivalent_cap000722 { cap000722 iff cap000722c }
check CapBenchEquivalent_cap000722 for 4
