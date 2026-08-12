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

pred inv5 {
some Teacher.Teaches
}

pred inv5c {
  some Teacher.Teaches
}

check correct { inv5 <=> inv5c}
pred under { inv5 and !inv5c}
pred over { !inv5 and inv5c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000204 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv5 and ((some capBenchR and some CapBenchB) or no CapBenchB))) }
pred cap000204c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv5 and ((some capBenchR and some CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap000204 { cap000204 iff cap000204c }
check CapBenchEquivalent_cap000204 for 4
