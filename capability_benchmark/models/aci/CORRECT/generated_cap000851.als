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

pred cap000851 { (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS)) }
pred cap000851c { ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS)) or (inv3 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchS))) }
assert CapBenchEquivalent_cap000851 { cap000851 iff cap000851c }
check CapBenchEquivalent_cap000851 for 4
