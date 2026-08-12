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
all p:Person | some (^Tutors.p & Teacher)
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

pred cap000373 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv15 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
pred cap000373c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv15 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchS))) }
assert CapBenchEquivalent_cap000373 { cap000373 iff cap000373c }
check CapBenchEquivalent_cap000373 for 4
