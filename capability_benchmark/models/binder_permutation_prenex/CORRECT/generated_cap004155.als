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

pred cap004155 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv15 and ((no CapBenchB or no CapBenchB) and no CapBenchA))) }
pred cap004155c { some a, b: CapBenchA | (b->a in capBenchR and (inv15 and ((no CapBenchB or no CapBenchB) and no CapBenchA))) }
assert CapBenchEquivalent_cap004155 { cap004155 iff cap004155c }
check CapBenchEquivalent_cap004155 for 4
