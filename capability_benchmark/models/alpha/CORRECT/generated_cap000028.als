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

pred inv8 {
all t:Teacher | lone t.Teaches
}

pred inv8c {
  all t:Teacher | lone t.Teaches
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000028 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv8 and ((some capBenchR and no CapBenchB) or some CapBenchA))) }
pred cap000028c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv8 and ((some capBenchR and no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap000028 { cap000028 iff cap000028c }
check CapBenchEquivalent_cap000028 for 4
