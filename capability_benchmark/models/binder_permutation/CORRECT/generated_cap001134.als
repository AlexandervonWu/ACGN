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

pred cap001134 { all x, y: CapBenchA | (x->y in capBenchR and (inv15 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchA))) }
pred cap001134c { all a, b: CapBenchA | (b->a in capBenchR and (inv15 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and no CapBenchA))) }
assert CapBenchEquivalent_cap001134 { cap001134 iff cap001134c }
check CapBenchEquivalent_cap001134 for 4
