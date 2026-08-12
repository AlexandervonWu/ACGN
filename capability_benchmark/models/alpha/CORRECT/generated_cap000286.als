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

pred inv13 {
Tutors in (Teacher->Student)
}

pred inv13c {
  Tutors in Teacher -> Student
}

check correct { inv13 <=> inv13c}
pred under { inv13 and !inv13c}
pred over { !inv13 and inv13c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000286 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR))) }
pred cap000286c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv13 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap000286 { cap000286 iff cap000286c }
check CapBenchEquivalent_cap000286 for 4
