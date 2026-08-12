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

pred cap004334 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS))) }
pred cap004334c { some a, b: CapBenchA | (b->a in capBenchR and (inv11 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap004334 { cap004334 iff cap004334c }
check CapBenchEquivalent_cap004334 for 4
