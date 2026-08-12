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

pred cap003229 { all x: CapBenchA | (x->x in capBenchR and (inv11 and ((some capBenchS or some capBenchR) or no CapBenchB)) and ((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003229c { all renamed: CapBenchA | (((no CapBenchA and no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv11 and ((some capBenchS or some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap003229 { cap003229 iff cap003229c }
check CapBenchEquivalent_cap003229 for 4
