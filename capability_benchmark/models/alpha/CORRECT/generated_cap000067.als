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

pred cap000067 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv5 and ((no CapBenchB or some CapBenchA) and some CapBenchB))) }
pred cap000067c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv5 and ((no CapBenchB or some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap000067 { cap000067 iff cap000067c }
check CapBenchEquivalent_cap000067 for 4
