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

pred cap003391 { all x: CapBenchA | (x->x in capBenchR and (inv15 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA)) }
pred cap003391c { all renamed: CapBenchA | (((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA) and renamed->renamed in capBenchR and (inv15 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003391 { cap003391 iff cap003391c }
check CapBenchEquivalent_cap003391 for 4
