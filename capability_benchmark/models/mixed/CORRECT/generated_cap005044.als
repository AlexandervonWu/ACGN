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

pred cap005044 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((some capBenchR and some capBenchS) or some CapBenchA)) and ((some CapBenchB or no CapBenchB) or no CapBenchB))) }
pred cap005044c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or no CapBenchB) or no CapBenchB)) or (not (inv11 and ((some capBenchR and some capBenchS) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005044 { cap005044 iff cap005044c }
check CapBenchEquivalent_cap005044 for 4
