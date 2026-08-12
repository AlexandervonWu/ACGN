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

pred cap001583 { ((all x: CapBenchA | x->x in capBenchR) or (inv3 and ((no CapBenchB or no CapBenchA) and some CapBenchB))) }
pred cap001583c { (all x: CapBenchA | (x->x in capBenchR or (inv3 and ((no CapBenchB or no CapBenchA) and some CapBenchB)))) }
assert CapBenchEquivalent_cap001583 { cap001583 iff cap001583c }
check CapBenchEquivalent_cap001583 for 4
