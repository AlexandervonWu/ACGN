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

pred cap001965 { ((all x: CapBenchA | x->x in capBenchR) or (inv11 and ((some CapBenchB or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap001965c { (all x: CapBenchA | (x->x in capBenchR or (inv11 and ((some CapBenchB or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap001965 { cap001965 iff cap001965c }
check CapBenchEquivalent_cap001965 for 4
