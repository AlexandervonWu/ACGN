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

pred cap004234 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv8 and ((no CapBenchA and some capBenchS) and no CapBenchB))) }
pred cap004234c { some a, b: CapBenchA | (b->a in capBenchR and (inv8 and ((no CapBenchA and some capBenchS) and no CapBenchB))) }
assert CapBenchEquivalent_cap004234 { cap004234 iff cap004234c }
check CapBenchEquivalent_cap004234 for 4
