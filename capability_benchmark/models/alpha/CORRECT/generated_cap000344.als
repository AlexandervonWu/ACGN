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

pred cap000344 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv11 and ((some CapBenchA and no CapBenchB) or some capBenchS))) }
pred cap000344c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv11 and ((some CapBenchA and no CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000344 { cap000344 iff cap000344c }
check CapBenchEquivalent_cap000344 for 4
