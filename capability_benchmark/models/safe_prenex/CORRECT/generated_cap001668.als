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

pred cap001668 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((some CapBenchA and some capBenchS) or no CapBenchA))) }
pred cap001668c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((some CapBenchA and some capBenchS) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001668 { cap001668 iff cap001668c }
check CapBenchEquivalent_cap001668 for 4
