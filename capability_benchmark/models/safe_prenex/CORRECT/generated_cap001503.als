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
some Teacher.Teaches
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

pred cap001503 { ((all x: CapBenchA | x->x in capBenchR) or (inv5 and ((no CapBenchB or some CapBenchA) and some CapBenchA))) }
pred cap001503c { (all x: CapBenchA | (x->x in capBenchR or (inv5 and ((no CapBenchB or some CapBenchA) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001503 { cap001503 iff cap001503c }
check CapBenchEquivalent_cap001503 for 4
