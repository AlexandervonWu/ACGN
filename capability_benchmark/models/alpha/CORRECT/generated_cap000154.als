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

pred cap000154 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv11 and ((no CapBenchA and no CapBenchB) and no CapBenchA))) }
pred cap000154c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv11 and ((no CapBenchA and no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap000154 { cap000154 iff cap000154c }
check CapBenchEquivalent_cap000154 for 4
