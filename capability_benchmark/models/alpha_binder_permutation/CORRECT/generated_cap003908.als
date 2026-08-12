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

pred cap003908 { all x, y: CapBenchA | (x->y in capBenchR and (inv11 and ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap003908c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv11 and ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003908 { cap003908 iff cap003908c }
check CapBenchEquivalent_cap003908 for 4
