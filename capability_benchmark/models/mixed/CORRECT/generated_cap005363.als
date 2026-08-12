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
all c: Class | some c.Groups implies (some t: Teacher | t in Teaches.c)
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

pred cap005363 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((no CapBenchB or some capBenchS) and some capBenchS)) and ((some CapBenchA and no CapBenchB) or some CapBenchA))) }
pred cap005363c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and no CapBenchB) or some CapBenchA)) or (not (inv11 and ((no CapBenchB or some capBenchS) and some capBenchS)))) }
assert CapBenchEquivalent_cap005363 { cap005363 iff cap005363c }
check CapBenchEquivalent_cap005363 for 4
