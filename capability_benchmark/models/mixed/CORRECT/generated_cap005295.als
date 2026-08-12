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

pred cap005295 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR)) and ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap005295c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv11 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and some capBenchR)))) }
assert CapBenchEquivalent_cap005295 { cap005295 iff cap005295c }
check CapBenchEquivalent_cap005295 for 4
