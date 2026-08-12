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

pred cap003081 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some CapBenchB or no CapBenchA) or some CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB)) }
pred cap003081c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and no CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((some CapBenchB or no CapBenchA) or some CapBenchB))) }
assert CapBenchEquivalent_cap003081 { cap003081 iff cap003081c }
check CapBenchEquivalent_cap003081 for 4
