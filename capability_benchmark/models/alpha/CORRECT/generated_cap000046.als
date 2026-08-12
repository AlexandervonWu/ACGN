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

pred cap000046 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA))) }
pred cap000046c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv8 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchS) and some CapBenchA))) }
assert CapBenchEquivalent_cap000046 { cap000046 iff cap000046c }
check CapBenchEquivalent_cap000046 for 4
