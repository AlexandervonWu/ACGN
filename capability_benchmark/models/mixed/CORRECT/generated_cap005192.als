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
no p:Person | p in Teacher and p in Student
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

pred cap005192 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv3 and ((some CapBenchA and some CapBenchA) or no CapBenchB)) and ((some capBenchS or some capBenchS) or some capBenchS))) }
pred cap005192c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or some capBenchS) or some capBenchS)) or (not (inv3 and ((some CapBenchA and some CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap005192 { cap005192 iff cap005192c }
check CapBenchEquivalent_cap005192 for 4
