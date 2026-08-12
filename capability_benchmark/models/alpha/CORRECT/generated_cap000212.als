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

pred inv4 {
all p: Person | p in Teacher or p in Student
}

pred inv4c {
 Person in Student + Teacher
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000212 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((some capBenchR and no CapBenchA) or no CapBenchB))) }
pred cap000212c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv4 and ((some capBenchR and no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap000212 { cap000212 iff cap000212c }
check CapBenchEquivalent_cap000212 for 4
