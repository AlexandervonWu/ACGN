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

pred cap003454 { all x: CapBenchA | (x->x in capBenchR and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) }
pred cap003454c { all renamed: CapBenchA | (((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB) and renamed->renamed in capBenchR and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003454 { cap003454 iff cap003454c }
check CapBenchEquivalent_cap003454 for 4
