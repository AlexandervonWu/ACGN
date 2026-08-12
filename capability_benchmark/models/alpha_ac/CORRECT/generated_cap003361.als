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
all disj t: Teacher | lone t.Teaches
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

pred cap003361 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((some CapBenchB or some capBenchS) or some capBenchS)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA)) }
pred cap003361c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and some CapBenchA) and renamed->renamed in capBenchR and (inv8 and ((some CapBenchB or some capBenchS) or some capBenchS))) }
assert CapBenchEquivalent_cap003361 { cap003361 iff cap003361c }
check CapBenchEquivalent_cap003361 for 4
