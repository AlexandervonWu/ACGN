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

pred cap002365 { no x: CapBenchA | (x->x in capBenchR and (inv2 and ((some capBenchS or some capBenchS) or some capBenchS))) }
pred cap002365c { all x: CapBenchA | not (x->x in capBenchR and (inv2 and ((some capBenchS or some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap002365 { cap002365 iff cap002365c }
check CapBenchEquivalent_cap002365 for 4
