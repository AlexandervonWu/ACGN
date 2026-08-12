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

pred cap004274 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv15 and ((no CapBenchA and no CapBenchA) and some capBenchR))) }
pred cap004274c { some a, b: CapBenchA | (b->a in capBenchR and (inv15 and ((no CapBenchA and no CapBenchA) and some capBenchR))) }
assert CapBenchEquivalent_cap004274 { cap004274 iff cap004274c }
check CapBenchEquivalent_cap004274 for 4
