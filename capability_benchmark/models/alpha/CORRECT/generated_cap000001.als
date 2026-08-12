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

pred cap000001 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv12 and ((some CapBenchB or some CapBenchA) or some CapBenchA))) }
pred cap000001c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv12 and ((some CapBenchB or some CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap000001 { cap000001 iff cap000001c }
check CapBenchEquivalent_cap000001 for 4
