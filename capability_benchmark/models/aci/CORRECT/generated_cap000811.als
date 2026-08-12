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

pred cap000811 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
pred cap000811c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv2 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
assert CapBenchEquivalent_cap000811 { cap000811 iff cap000811c }
check CapBenchEquivalent_cap000811 for 4
