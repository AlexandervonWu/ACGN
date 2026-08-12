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

pred cap005180 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) and ((some CapBenchB or some capBenchR) or some capBenchS))) }
pred cap005180c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some capBenchR) or some capBenchS)) or (not (inv3 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005180 { cap005180 iff cap005180c }
check CapBenchEquivalent_cap005180 for 4
