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

pred cap002077 { no x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchS or some CapBenchB) or some CapBenchB))) }
pred cap002077c { all x: CapBenchA | not (x->x in capBenchR and (inv3 and ((some capBenchS or some CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap002077 { cap002077 iff cap002077c }
check CapBenchEquivalent_cap002077 for 4
