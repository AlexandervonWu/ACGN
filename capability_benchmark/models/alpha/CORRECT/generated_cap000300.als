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

pred cap000300 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchR and some capBenchS) or some capBenchR))) }
pred cap000300c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv1 and ((some capBenchR and some capBenchS) or some capBenchR))) }
assert CapBenchEquivalent_cap000300 { cap000300 iff cap000300c }
check CapBenchEquivalent_cap000300 for 4
