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

pred cap002511 { not (((inv8 and ((no CapBenchB or some CapBenchB) and some CapBenchA))) since (((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap002511c { ((not (inv8 and ((no CapBenchB or some CapBenchB) and some CapBenchA))) triggered (not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap002511 { cap002511 iff cap002511c }
check CapBenchEquivalent_cap002511 for 4
