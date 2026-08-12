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

pred cap001621 { ((all x: CapBenchA | x->x in capBenchR) or (inv8 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
pred cap001621c { (all x: CapBenchA | (x->x in capBenchR or (inv8 and ((some CapBenchB or CapBenchA in CapBenchA + CapBenchB) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001621 { cap001621 iff cap001621c }
check CapBenchEquivalent_cap001621 for 4
