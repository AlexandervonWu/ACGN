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

pred cap004377 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv11 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap004377c { some a, b: CapBenchA | (b->a in capBenchR and (inv11 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap004377 { cap004377 iff cap004377c }
check CapBenchEquivalent_cap004377 for 4
