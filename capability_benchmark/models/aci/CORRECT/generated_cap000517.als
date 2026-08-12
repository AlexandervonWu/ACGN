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

pred cap000517 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv3 and ((some CapBenchB or no CapBenchA) or some CapBenchA))) }
pred cap000517c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv3 and ((some CapBenchB or no CapBenchA) or some CapBenchA))) }
assert CapBenchEquivalent_cap000517 { cap000517 iff cap000517c }
check CapBenchEquivalent_cap000517 for 4
