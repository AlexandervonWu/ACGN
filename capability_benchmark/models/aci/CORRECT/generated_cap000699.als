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

pred cap000699 { ((inv11 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB)) or ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS) or ((no CapBenchA and some capBenchR) and some CapBenchA)) }
pred cap000699c { (((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS) or ((no CapBenchA and some capBenchR) and some CapBenchA) or (inv11 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap000699 { cap000699 iff cap000699c }
check CapBenchEquivalent_cap000699 for 4
