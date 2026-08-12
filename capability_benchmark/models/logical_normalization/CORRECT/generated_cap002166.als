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

pred inv12 {
all t : Teacher | some t.Teaches.Groups
}

pred inv12c {
 all x:Teacher | some x.Teaches.Groups
}

check correct { inv12 <=> inv12c}
pred under { inv12 and !inv12c}
pred over { !inv12 and inv12c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002166 { not (all x: CapBenchA | (x->x in capBenchR and (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA)))) }
pred cap002166c { some x: CapBenchA | not (x->x in capBenchR and (inv12 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap002166 { cap002166 iff cap002166c }
check CapBenchEquivalent_cap002166 for 4
