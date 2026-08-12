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

pred cap002401 { no x: CapBenchA | (x->x in capBenchR and (inv15 and ((some CapBenchB or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap002401c { all x: CapBenchA | not (x->x in capBenchR and (inv15 and ((some CapBenchB or no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002401 { cap002401 iff cap002401c }
check CapBenchEquivalent_cap002401 for 4
