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
all t : Teacher | all c1, c2 : Class | t->c1 in Teaches and t->c2 in Teaches implies c1 = c2
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

pred cap003306 { all x: CapBenchA | (x->x in capBenchR and (inv8 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap003306c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv8 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchR))) }
assert CapBenchEquivalent_cap003306 { cap003306 iff cap003306c }
check CapBenchEquivalent_cap003306 for 4
