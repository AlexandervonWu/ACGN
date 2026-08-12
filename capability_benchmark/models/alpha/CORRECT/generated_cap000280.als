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
some c : Class, p : Person | p -> c in Teaches and p in Teacher
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

pred cap000280 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv5 and ((some CapBenchA and no CapBenchB) or some capBenchR))) }
pred cap000280c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv5 and ((some CapBenchA and no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000280 { cap000280 iff cap000280c }
check CapBenchEquivalent_cap000280 for 4
