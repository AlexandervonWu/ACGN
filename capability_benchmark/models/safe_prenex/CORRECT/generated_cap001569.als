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

pred cap001569 { ((all x: CapBenchA | x->x in capBenchR) or (inv8 and ((some capBenchS or some CapBenchA) or some CapBenchB))) }
pred cap001569c { (all x: CapBenchA | (x->x in capBenchR or (inv8 and ((some capBenchS or some CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap001569 { cap001569 iff cap001569c }
check CapBenchEquivalent_cap001569 for 4
