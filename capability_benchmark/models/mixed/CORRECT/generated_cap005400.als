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

pred cap005400 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv11 and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
pred cap005400c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) or (not (inv11 and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005400 { cap005400 iff cap005400c }
check CapBenchEquivalent_cap005400 for 4
