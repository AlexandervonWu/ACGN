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

pred cap000725 { (inv3 and ((some CapBenchB or some capBenchR) or no CapBenchB)) }
pred cap000725c { ((inv3 and ((some CapBenchB or some capBenchR) or no CapBenchB)) or (inv3 and ((some CapBenchB or some capBenchR) or no CapBenchB))) }
assert CapBenchEquivalent_cap000725 { cap000725 iff cap000725c }
check CapBenchEquivalent_cap000725 for 4
