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

pred inv12 {
Teaches.Groups.Group.Person & Teacher = Teacher
}

pred inv12c {
 all x:Teacher | some x.Teaches.Groups
}

check correct { inv12 <=> inv12c}
pred under { inv12 and !inv12c}
pred over { !inv12 and inv12c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000334 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS))) }
pred cap000334c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap000334 { cap000334 iff cap000334c }
check CapBenchEquivalent_cap000334 for 4
