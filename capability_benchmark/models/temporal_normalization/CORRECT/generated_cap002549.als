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

pred cap002549 { not eventually ((inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap002549c { always (not (inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap002549 { cap002549 iff cap002549c }
check CapBenchEquivalent_cap002549 for 4
