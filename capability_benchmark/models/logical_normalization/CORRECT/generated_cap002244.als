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

pred cap002244 { not (all x: CapBenchA | (x->x in capBenchR and (inv11 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)))) }
pred cap002244c { some x: CapBenchA | not (x->x in capBenchR and (inv11 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
assert CapBenchEquivalent_cap002244 { cap002244 iff cap002244c }
check CapBenchEquivalent_cap002244 for 4
