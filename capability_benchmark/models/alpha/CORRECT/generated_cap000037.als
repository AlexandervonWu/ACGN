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

pred cap000037 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv11 and ((some capBenchS or some capBenchR) or some CapBenchA))) }
pred cap000037c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv11 and ((some capBenchS or some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap000037 { cap000037 iff cap000037c }
check CapBenchEquivalent_cap000037 for 4
