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

pred cap001633 { ((all x: CapBenchA | x->x in capBenchR) or (inv15 and ((some capBenchS or some CapBenchA) or no CapBenchA))) }
pred cap001633c { (all x: CapBenchA | (x->x in capBenchR or (inv15 and ((some capBenchS or some CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001633 { cap001633 iff cap001633c }
check CapBenchEquivalent_cap001633 for 4
