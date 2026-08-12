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
all x: Person | x in Student implies x not in Teacher
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

pred cap000287 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR))) }
pred cap000287c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap000287 { cap000287 iff cap000287c }
check CapBenchEquivalent_cap000287 for 4
