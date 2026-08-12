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

pred cap000265 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv15 and ((some CapBenchB or some CapBenchB) or some capBenchR))) }
pred cap000265c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv15 and ((some CapBenchB or some CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000265 { cap000265 iff cap000265c }
check CapBenchEquivalent_cap000265 for 4
