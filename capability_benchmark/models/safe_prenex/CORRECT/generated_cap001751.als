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

pred cap001751 { ((all x: CapBenchA | x->x in capBenchR) or (inv3 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB))) }
pred cap001751c { (all x: CapBenchA | (x->x in capBenchR or (inv3 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)))) }
assert CapBenchEquivalent_cap001751 { cap001751 iff cap001751c }
check CapBenchEquivalent_cap001751 for 4
