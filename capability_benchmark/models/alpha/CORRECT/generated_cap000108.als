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

pred cap000108 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv12 and ((some capBenchR and some capBenchS) or some CapBenchB))) }
pred cap000108c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv12 and ((some capBenchR and some capBenchS) or some CapBenchB))) }
assert CapBenchEquivalent_cap000108 { cap000108 iff cap000108c }
check CapBenchEquivalent_cap000108 for 4
