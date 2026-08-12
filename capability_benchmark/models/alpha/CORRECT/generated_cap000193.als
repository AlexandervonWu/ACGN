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

pred inv3 {
no (Teacher & Student)
}

pred inv3c {
 no Student & Teacher 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000193 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((some CapBenchB or some CapBenchA) or no CapBenchB))) }
pred cap000193c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((some CapBenchB or some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap000193 { cap000193 iff cap000193c }
check CapBenchEquivalent_cap000193 for 4
