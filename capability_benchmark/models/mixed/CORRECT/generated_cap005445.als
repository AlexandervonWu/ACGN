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
all c: Class | some Person.(c.Groups) implies some t:Teacher | t in Teaches.c
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

pred cap005445 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and some capBenchS) and some CapBenchB))) }
pred cap005445c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some capBenchS) and some CapBenchB)) or (not (inv11 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005445 { cap005445 iff cap005445c }
check CapBenchEquivalent_cap005445 for 4
