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

pred inv15 {
all p:Person | some t:Teacher | t in p.^(~Tutors)
}

pred inv15c {
  all p:Person | some Teacher&(^Tutors).p
}

check correct { inv15 <=> inv15c}
pred under { inv15 and !inv15c}
pred over { !inv15 and inv15c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001575 { ((all x: CapBenchA | x->x in capBenchR) or (inv15 and ((no CapBenchB or some CapBenchB) and some CapBenchB))) }
pred cap001575c { (all x: CapBenchA | (x->x in capBenchR or (inv15 and ((no CapBenchB or some CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap001575 { cap001575 iff cap001575c }
check CapBenchEquivalent_cap001575 for 4
