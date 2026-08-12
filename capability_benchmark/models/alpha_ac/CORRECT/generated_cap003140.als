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

pred cap003140 { all x: CapBenchA | (x->x in capBenchR and (inv11 and ((some capBenchR and some CapBenchB) or no CapBenchA)) and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) }
pred cap003140c { all renamed: CapBenchA | (((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some capBenchR) and renamed->renamed in capBenchR and (inv11 and ((some capBenchR and some CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003140 { cap003140 iff cap003140c }
check CapBenchEquivalent_cap003140 for 4
