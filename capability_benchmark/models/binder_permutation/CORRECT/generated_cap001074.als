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

pred cap001074 { all x, y: CapBenchA | (x->y in capBenchR and (inv8 and ((no CapBenchA and some CapBenchB) and some CapBenchB))) }
pred cap001074c { all a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((no CapBenchA and some CapBenchB) and some CapBenchB))) }
assert CapBenchEquivalent_cap001074 { cap001074 iff cap001074c }
check CapBenchEquivalent_cap001074 for 4
