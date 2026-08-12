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

pred cap001572 { ((some x: CapBenchA | x->x in capBenchR) and (inv11 and ((some CapBenchA and some CapBenchB) or some CapBenchB))) }
pred cap001572c { (some x: CapBenchA | (x->x in capBenchR and (inv11 and ((some CapBenchA and some CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001572 { cap001572 iff cap001572c }
check CapBenchEquivalent_cap001572 for 4
