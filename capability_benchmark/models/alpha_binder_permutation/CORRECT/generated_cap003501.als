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

pred inv11 {
all c : Class | (some c.Groups implies some (Teaches.c & Teacher))
}

pred inv11c {
  all c:Class | some c.Groups implies some Teacher&Teaches.c
}


check correct { inv11 <=> inv11c}
pred under { inv11 and !inv11c}
pred over { !inv11 and inv11c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003501 { all x, y: CapBenchA | (x->y in capBenchR and (inv11 and ((some CapBenchB or some CapBenchA) or some CapBenchA))) }
pred cap003501c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv11 and ((some CapBenchB or some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap003501 { cap003501 iff cap003501c }
check CapBenchEquivalent_cap003501 for 4
