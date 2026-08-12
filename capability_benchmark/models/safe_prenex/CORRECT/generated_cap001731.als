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

pred inv15 {
all p:Person | some (^Tutors.p & Teacher)
}

pred inv15c {
  all p:Person | some Teacher&(^Tutors).p
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001731 { ((all x: CapBenchA | x->x in capBenchR) or (inv15 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB))) }
pred cap001731c { (all x: CapBenchA | (x->x in capBenchR or (inv15 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001731 { cap001731 iff cap001731c }
check CapBenchEquivalent_cap001731 for 4
