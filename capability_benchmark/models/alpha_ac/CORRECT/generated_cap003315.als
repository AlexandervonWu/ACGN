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

pred cap003315 { all x: CapBenchA | (x->x in capBenchR and (inv15 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR)) and ((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap003315c { all renamed: CapBenchA | (((some CapBenchA and some capBenchS) or CapBenchA in CapBenchA + CapBenchB) and renamed->renamed in capBenchR and (inv15 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap003315 { cap003315 iff cap003315c }
check CapBenchEquivalent_cap003315 for 4
