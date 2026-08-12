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

pred inv1 {
Person = Student
}

pred inv1c {
  Person in Student
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000222 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB))) }
pred cap000222c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap000222 { cap000222 iff cap000222c }
check CapBenchEquivalent_cap000222 for 4
