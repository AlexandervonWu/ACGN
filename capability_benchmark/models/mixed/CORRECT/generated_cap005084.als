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

pred cap005084 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv8 and ((some capBenchR and no CapBenchA) or some CapBenchB)) and ((some CapBenchB or some CapBenchA) or some capBenchR))) }
pred cap005084c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some CapBenchA) or some capBenchR)) or (not (inv8 and ((some capBenchR and no CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005084 { cap005084 iff cap005084c }
check CapBenchEquivalent_cap005084 for 4
